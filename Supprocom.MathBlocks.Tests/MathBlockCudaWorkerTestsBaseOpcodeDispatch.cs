using System.Runtime.InteropServices;
using Supprocom.MathBlocks.Cuda;

[assembly: DefaultDllImportSearchPaths(DllImportSearchPath.SafeDirectories)]

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Calls the device module's <c>mathblocks_operation_dispatch</c> from a consumer-owned kernel with the public base opcode
/// (<see cref="MathBlockCudaOperationContract.Opcode"/>, the elementwise mask bits 0), as the package-only consumer does, and compares the
/// result bit for bit with CoreCLR. The elementwise dispatcher derives the argument kinds from the input slots.
/// </summary>
// The class name contains MathBlockCudaWorkerTests so that the standard CoreCLR filter, which excludes the CUDA execution classes by that name, leaves it out.
public sealed class MathBlockCudaWorkerTestsBaseOpcodeDispatch
{
    private const double Fill = -98_765.25d;
    private const int Alignment = 16;

    private static readonly Dictionary<string, (string Identity, Func<MathBlockValue[]> Inputs)> Cases = new(StringComparer.Ordinal)
    {
        ["base-opcode/unary-vector"] = ("elementwise.scalar.absolute@1", () => [Vector(-1.5d, 2d, -0d, 4d), Scalar(Fill)]),
        ["base-opcode/vector-scalar"] = ("elementwise.scalar.add@1", () => [Vector(1d, 2d, 3d), Scalar(0.5d), Scalar(Fill)]),
        ["base-opcode/scalar-vector"] = ("elementwise.scalar.subtract@1", () => [Scalar(0.5d), Vector(1d, 2d, 3d), Scalar(Fill)]),
        ["base-opcode/vector-vector"] = ("elementwise.scalar.multiply@1", () => [Vector(1d, 2d, 3d), Vector(0.25d, -4d, 8d), Scalar(Fill)]),
        ["base-opcode/sibling-vector-vector"] = ("elementwise-valid.scalar.divide@1", () => [Vector(1d, 2d, 3d), Vector(0.25d, 0d, 8d)])
    };

    /// <summary>Gets the case names.</summary>
    public static TheoryData<string> CaseNames => [.. Cases.Keys.Order(StringComparer.Ordinal)];

    // The launch and the resource lifetime stay in one visible path, as in the package-only consumer.
#pragma warning disable MA0051
    /// <summary>Verifies a consumer kernel that dispatches an elementwise form with the base opcode gets the CoreCLR result.</summary>
    [Theory]
    [MemberData(nameof(CaseNames))]
    public void CUDADeviceDispatchWithTheBaseOpcodeGivesTheCoreCLRResult(string name)
    {
        ArgumentException.ThrowIfNullOrEmpty(name);
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var (identity, create) = Cases[name];
        var inputs = create();
        var contract = MathBlockCudaDeviceModule.GetOperation(identity);
        Assert.True(contract.Opcode < 128, "The public opcode carries no mask.");
        var expected = contract.EvaluateCoreCLR(inputs);
        var plan = contract.PlanCUDA(inputs);

        var slotCount = inputs.Length + 1;
        var cursor = Align(slotCount * MathBlockCudaSlotLayout.Size);
        var inputOffsets = new int[inputs.Length];
        for (var index = 0; index < inputs.Length; index++)
        {
            var bytes = MathBlockCudaValueCodec.GetPayloadByteCount(inputs[index].Type.Kind, MathBlockCudaValueCodec.GetElementCount(inputs[index]));
            inputOffsets[index] = Allocate(ref cursor, bytes);
        }

        var outputBytes = MathBlockCudaValueCodec.GetPayloadByteCount(plan.OutputType.Kind, plan.OutputCapacity);
        var outputOffset = Allocate(ref cursor, outputBytes);
        var arenaBytes = Align(cursor);
        var host = Marshal.AllocHGlobal(arenaBytes);
        var device = 0ul;
        var module = IntPtr.Zero;
        var stream = IntPtr.Zero;
        var parameters = new List<IntPtr>();
        var parameterArray = IntPtr.Zero;
        try
        {
            for (var offset = 0; offset < arenaBytes; offset++)
                Marshal.WriteByte(host, offset, 0);
            CudaDriver.Initialize();
            CudaDriver.Require(CudaDriver.cuMemAlloc(out device, new UIntPtr((uint)arenaBytes)), "cuMemAlloc");
            for (var index = 0; index < inputs.Length; index++)
            {
                MathBlockCudaValueCodec.WriteValue(
                    host,
                    index * MathBlockCudaSlotLayout.Size,
                    inputOffsets[index],
                    inputOffsets[index] < 0 ? 0ul : device + (ulong)inputOffsets[index],
                    0ul,
                    MathBlockCudaValueCodec.GetElementCount(inputs[index]),
                    inputs[index]);
            }

            MathBlockCudaValueCodec.WriteHeader(
                host,
                inputs.Length * MathBlockCudaSlotLayout.Size,
                outputOffset < 0 ? 0ul : device + (ulong)outputOffset,
                0ul,
                plan.OutputCapacity,
                new MathBlockType(plan.OutputType.Kind, plan.OutputType.Unit, plan.OutputRows, plan.OutputColumns),
                valid: false);
            CudaDriver.Require(CudaDriver.cuMemcpyHtoD(device, host, new UIntPtr((uint)arenaBytes)), "cuMemcpyHtoD");

            var ptx = MathBlockCudaDeviceModule.CompilePtx(KernelSource, "base-opcode-dispatch.cu");
            CudaDriver.Require(CudaDriver.cuModuleLoadData(out module, ptx), "cuModuleLoadData");
            CudaDriver.Require(CudaDriver.cuModuleGetFunction(out var function, module, "base_opcode_dispatch"), "cuModuleGetFunction");
            CudaDriver.Require(CudaDriver.cuStreamCreate(out stream, 1), "cuStreamCreate");
            parameters.Add(AllocateUInt64(device));
            parameters.Add(AllocateInt32((int)contract.Family));
            parameters.Add(AllocateInt32(contract.Opcode));
            parameters.Add(AllocateInt32(inputs.Length));
            parameters.Add(AllocateInt32(inputs.Length));
            parameterArray = Marshal.AllocHGlobal(parameters.Count * IntPtr.Size);
            for (var index = 0; index < parameters.Count; index++)
                Marshal.WriteIntPtr(parameterArray, index * IntPtr.Size, parameters[index]);
            CudaDriver.Require(
                CudaDriver.cuLaunchKernel(function, 1, 1, 1, (uint)MathBlockCudaDeviceModule.DispatcherBlockSize, 1, 1, 0, stream, parameterArray, IntPtr.Zero),
                "cuLaunchKernel");
            CudaDriver.Require(CudaDriver.cuStreamSynchronize(stream), "cuStreamSynchronize");
            CudaDriver.Require(CudaDriver.cuMemcpyDtoH(host, device, new UIntPtr((uint)arenaBytes)), "cuMemcpyDtoH");

            var actual = MathBlockCudaValueCodec.ReadValue(
                host,
                inputs.Length * MathBlockCudaSlotLayout.Size,
                outputOffset,
                expected.Type);
            Assert.Equal(expected.IsValid, actual.IsValid);
            Assert.True(expected.IsValid, "The case is meant to be valid.");
            if (expected.Type.Kind == MathBlockValueKind.BooleanVector)
            {
                Assert.Equal(expected.AsBooleanVector().ToArray(), actual.AsBooleanVector().ToArray());
            }
            else
            {
                Assert.Equal(
                    expected.AsVector().Select(BitConverter.DoubleToInt64Bits).ToArray(),
                    actual.AsVector().Select(BitConverter.DoubleToInt64Bits).ToArray());
            }
        }
        finally
        {
            for (var index = 0; index < parameters.Count; index++)
                Marshal.FreeHGlobal(parameters[index]);
            if (parameterArray != IntPtr.Zero)
                Marshal.FreeHGlobal(parameterArray);
            if (stream != IntPtr.Zero)
                _ = CudaDriver.cuStreamDestroy(stream);
            if (module != IntPtr.Zero)
                _ = CudaDriver.cuModuleUnload(module);
            if (device != 0ul)
                _ = CudaDriver.cuMemFree(device);
            Marshal.FreeHGlobal(host);
        }
    }

#pragma warning restore MA0051

    // NVRTC ignores source line endings; this is not a fingerprinted fixture.
#pragma warning disable MA0136
    private const string KernelSource = """
        extern "C" __global__ void base_opcode_dispatch(MathBlockSlot* slots, int family, int opcode, int input_count, int output_slot)
        {
            const MathBlockSlot* inputs[8];
            for (int index = 0; index < input_count; ++index)
                inputs[index] = &slots[index];
            mathblocks_operation_dispatch(family, opcode, inputs, input_count, &slots[output_slot]);
        }
        """;
#pragma warning restore MA0136

    private static MathBlockValue Vector(params double[] values) => MathBlockValue.Vector(values);

    private static MathBlockValue Scalar(double value) => MathBlockValue.Scalar(value);

    private static int Align(int value) => (value + Alignment - 1) & -Alignment;

    private static int Allocate(ref int cursor, int bytes)
    {
        if (bytes == 0)
            return -1;
        cursor = Align(cursor);
        var offset = cursor;
        cursor += bytes;
        return offset;
    }

    private static IntPtr AllocateUInt64(ulong value)
    {
        var pointer = Marshal.AllocHGlobal(sizeof(ulong));
        Marshal.WriteInt64(pointer, unchecked((long)value));
        return pointer;
    }

    private static IntPtr AllocateInt32(int value)
    {
        var pointer = Marshal.AllocHGlobal(sizeof(int));
        Marshal.WriteInt32(pointer, value);
        return pointer;
    }

    private static class CudaDriver
    {
        static CudaDriver()
        {
            if (!OperatingSystem.IsWindows())
            {
                NativeLibrary.SetDllImportResolver(
                    typeof(CudaDriver).Assembly,
                    static (name, _, _) =>
                        string.Equals(name, "nvcuda.dll", StringComparison.Ordinal)
                            ? LoadCuda()
                            : IntPtr.Zero);
            }
        }

        public static void Initialize()
        {
            Require(cuInit(0), "cuInit");
            Require(cuDeviceGet(out var device, 0), "cuDeviceGet");
            Require(cuDevicePrimaryCtxRetain(out var context, device), "cuDevicePrimaryCtxRetain");
            Require(cuCtxSetCurrent(context), "cuCtxSetCurrent");
        }

        public static void Require(int result, string operation)
        {
            if (result != 0)
                throw new InvalidOperationException($"{operation} failed with CUDA result {result}.");
        }

        private static IntPtr LoadCuda()
        {
            if (NativeLibrary.TryLoad("libcuda.so.1", out var handle))
                return handle;
            return NativeLibrary.TryLoad("libcuda.so", out handle) ? handle : IntPtr.Zero;
        }

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuInit(uint flags);

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuDeviceGet(out int device, int ordinal);

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuDevicePrimaryCtxRetain(out IntPtr context, int device);

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuCtxSetCurrent(IntPtr context);

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuModuleLoadData(out IntPtr module, byte[] image);

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi,
            BestFitMapping = false, ThrowOnUnmappableChar = true)]
        public static extern int cuModuleGetFunction(
            out IntPtr function,
            IntPtr module,
            [MarshalAs(UnmanagedType.LPUTF8Str)] string name);

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuModuleUnload(IntPtr module);

        [DllImport("nvcuda.dll", EntryPoint = "cuMemAlloc_v2", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuMemAlloc(out ulong devicePointer, UIntPtr bytes);

        [DllImport("nvcuda.dll", EntryPoint = "cuMemFree_v2", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuMemFree(ulong devicePointer);

        [DllImport("nvcuda.dll", EntryPoint = "cuMemcpyHtoD_v2", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuMemcpyHtoD(ulong destination, IntPtr source, UIntPtr bytes);

        [DllImport("nvcuda.dll", EntryPoint = "cuMemcpyDtoH_v2", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuMemcpyDtoH(IntPtr destination, ulong source, UIntPtr bytes);

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuStreamCreate(out IntPtr stream, uint flags);

        [DllImport("nvcuda.dll", EntryPoint = "cuStreamDestroy_v2", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuStreamDestroy(IntPtr stream);

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuStreamSynchronize(IntPtr stream);

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuLaunchKernel(
            IntPtr function,
            uint gridX,
            uint gridY,
            uint gridZ,
            uint blockX,
            uint blockY,
            uint blockZ,
            uint sharedMemoryBytes,
            IntPtr stream,
            IntPtr kernelParameters,
            IntPtr extra);
    }
}
