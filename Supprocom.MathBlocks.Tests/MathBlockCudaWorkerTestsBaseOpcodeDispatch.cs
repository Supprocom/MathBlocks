using System.Runtime.InteropServices;
using Supprocom.MathBlocks.Cuda;

[assembly: DefaultDllImportSearchPaths(DllImportSearchPath.SafeDirectories)]

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Calls the device module's <c>mathblocks_operation_dispatch</c> from a consumer-owned kernel with the public base opcode
/// (<see cref="MathBlockCudaOperationContract.Opcode"/>, the elementwise mask bits 0), as the package-only consumer does, and compares the
/// result bit for bit with CoreCLR. The elementwise dispatcher derives the argument kinds from the input slots.
/// </summary>
[Trait("Category", "CudaDevice")]
public sealed class MathBlockCudaWorkerTestsBaseOpcodeDispatch
{
    private const double Fill = -98_765.25d;
    private const int Alignment = 16;

    private static readonly Dictionary<string, (string Identity, Func<MathBlockValue[]> Inputs)> Cases = new(StringComparer.Ordinal)
    {
        ["base-opcode/unary-vector"] = ("elementwise.scalar.negate@1", () => [Vector(-1.5d, 2d, -0d, 4d), Scalar(Fill)]),
        ["base-opcode/vector-scalar"] = ("elementwise.scalar.maximum@1", () => [Vector(1d, 2d, 3d), Scalar(0.5d), Scalar(Fill)]),
        ["base-opcode/scalar-vector"] = ("elementwise.scalar.minimum@1", () => [Scalar(0.5d), Vector(1d, 2d, 3d), Scalar(Fill)]),
        ["base-opcode/vector-vector"] = ("elementwise.scalar.maximum@1", () => [Vector(1d, 2d, 3d), Vector(0.25d, -4d, 8d), Scalar(Fill)]),
        ["base-opcode/sibling-vector-vector"] = ("elementwise-valid.scalar.maximum@1", () => [Vector(1d, 2d, 3d), Vector(0.25d, -4d, 8d)]),
        // Rows outside the domain of logit: invalid on CoreCLR, so the fill path of the dispatcher is checked too.
        ["base-opcode/unary-vector-invalid-rows"] = ("elementwise.scalar.logit@1", () => [Vector(0.25d, 2d, 0.5d, -1d), Scalar(Fill)]),
        // The scalar operations whose vector twin has whole-value validity: one bad row (divide by 0, a logarithm or root out of domain, overflow) is invalid alone.
        ["lift/absolute"] = ("elementwise.scalar.absolute@1", () => [Vector(-2d, -0.5d, 0d, 3d, -1e300d), Scalar(Fill)]),
        ["lift/add"] = ("elementwise.scalar.add@1", () => [Vector(1d, 2d, 1e308d, -1d), Vector(2d, -2d, 1e308d, 1d), Scalar(Fill)]),
        ["lift/subtract"] = ("elementwise.scalar.subtract@1", () => [Vector(5d, 2d, -1e308d, 1d), Vector(2d, 2d, 1e308d, -1d), Scalar(Fill)]),
        ["lift/multiply"] = ("elementwise.scalar.multiply@1", () => [Vector(2d, -3d, 1e200d, 0d), Vector(3d, 3d, 1e200d, 5d), Scalar(Fill)]),
        ["lift/divide"] = ("elementwise.scalar.divide@1", () => [Vector(6d, 1d, -3d, 1d, 0d, 1e308d), Vector(3d, 0d, 2d, 4d, 5d, 1e-10d), Scalar(Fill)]),
        ["lift/divide-scalar-divisor"] = ("elementwise.scalar.divide@1", () => [Vector(6d, 1d, -3d), Scalar(0d), Scalar(Fill)]),
        ["lift/power"] = ("elementwise.scalar.power@1", () => [Vector(2d, 9d, -8d, 2d, 0d, 10d), Vector(3d, 0.5d, 0.5d, -1d, -1d, 400d), Scalar(Fill)]),
        ["lift/natural-logarithm"] = ("elementwise.scalar.natural-logarithm@1", () => [Vector(1d, 2d, 0.5d, 0d, -1d, 10d), Scalar(Fill)]),
        ["lift/square-root"] = ("elementwise.scalar.square-root@1", () => [Vector(0d, 1d, 4d, 2d, -1d, 0.25d), Scalar(Fill)]),
        ["lift/square"] = ("elementwise.scalar.square@1", () => [Vector(-2d, -0.5d, 0d, 1.5d, 1e200d, 3d), Scalar(Fill)]),
        ["lift/exponential"] = ("elementwise.scalar.exponential@1", () => [Vector(0d, 1d, -1d, 0.5d, 800d, -800d), Scalar(Fill)]),
        ["lift/positive-part"] = ("elementwise.scalar.positive-part@1", () => [Vector(-2d, -0.5d, 0d, 0.5d, 3d), Scalar(Fill)]),
        ["lift/sign"] = ("elementwise.scalar.sign@1", () => [Vector(-2d, -0.5d, 0d, 0.5d, 3d), Scalar(Fill)]),
        ["lift/sibling-divide"] = ("elementwise-valid.scalar.divide@1", () => [Vector(6d, 1d, -3d, 1e308d), Vector(3d, 0d, 2d, 1e-10d)]),
        ["lift/sibling-natural-logarithm"] = ("elementwise-valid.scalar.natural-logarithm@1", () => [Vector(1d, 0d, -1d, 5d)])
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
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var (identity, create) = Cases[name];
        RunDispatch(identity, create(), MathBlockCudaDeviceModule.DispatcherBlockSize);
    }

    /// <summary>
    /// Verifies the dispatcher gives the CoreCLR result at block sizes of 1, 7, 32, 100, 129, 256 and the device maximum, with the scratch that
    /// <see cref="MathBlockCudaOperationContract.PlanCUDA(IReadOnlyList{MathBlockValue}, MathBlockDomainOptions, int)"/> plans for the block size.
    /// </summary>
    [Theory]
    [MemberData(nameof(BlockSizedCaseNames))]
    public void CUDADeviceDispatchGivesTheCoreCLRResultAtEveryBlockSize(string name, int blockSize)
    {
        ArgumentException.ThrowIfNullOrEmpty(name);
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var (identity, create) = BlockSizedCases[name];
        RunDispatch(identity, create(), blockSize == 0 ? DeviceMaximumThreadsPerBlock() : blockSize);
    }

    // Argument rows a MathBlockValue cannot hold: (input index, row) is the patched vector row, and row -1 patches a scalar slot.
    private static readonly Dictionary<string, (string Identity, Func<MathBlockValue[]> Inputs, (int Input, int Row, double Value)[] Patches)> NonFiniteCases = new(StringComparer.Ordinal)
    {
        // maximum(1, -Inf) is finite, so only the input check makes these rows invalid.
        ["non-finite/vector-vector"] = (
            "elementwise.scalar.maximum@1",
            () => [Vector(1d, 2d, 3d, 4d, 5d, 6d, 7d), Vector(0d, 0d, 0d, 0d, 0d, 0d, 0d), Scalar(Fill)],
            [(0, 1, double.PositiveInfinity), (0, 2, double.NegativeInfinity), (0, 3, double.NaN), (1, 4, double.NegativeInfinity), (1, 5, double.NaN), (1, 6, double.PositiveInfinity)]),
        ["non-finite/vector-scalar-broadcast"] = (
            "elementwise.scalar.maximum@1",
            () => [Vector(1d, 2d, 3d), Scalar(0.5d), Scalar(Fill)],
            [(1, -1, double.NegativeInfinity)]),
        ["non-finite/scalar-vector-broadcast"] = (
            "elementwise.scalar.maximum@1",
            () => [Scalar(0.5d), Vector(1d, 2d, 3d), Scalar(Fill)],
            [(0, -1, double.NaN)]),
        ["non-finite/unary"] = (
            "elementwise.scalar.negate@1",
            () => [Vector(1d, 2d, 3d, 4d), Scalar(Fill)],
            [(0, 0, double.PositiveInfinity), (0, 2, double.NaN)]),
        // divide(1, +-Inf) is 0 and valid without the input check; with it the row is invalid.
        ["non-finite/divide"] = (
            "elementwise.scalar.divide@1",
            () => [Vector(1d, 1d, 1d, 4d, 6d), Vector(2d, 2d, 2d, 2d, 3d), Scalar(Fill)],
            [(1, 0, double.PositiveInfinity), (1, 1, double.NegativeInfinity), (1, 2, double.NaN), (0, 3, double.PositiveInfinity)]),
        ["non-finite/square-root"] = (
            "elementwise.scalar.square-root@1",
            () => [Vector(4d, 9d, 16d), Scalar(Fill)],
            [(0, 0, double.PositiveInfinity), (0, 2, double.NaN)]),
        ["non-finite/sibling"] = (
            "elementwise-valid.scalar.maximum@1",
            () => [Vector(1d, 2d, 3d, 4d), Vector(0d, 0d, 0d, 0d)],
            [(0, 1, double.NegativeInfinity), (1, 3, double.NaN)])
    };

    /// <summary>Gets the non-finite case names.</summary>
    public static TheoryData<string> NonFiniteCaseNames => [.. NonFiniteCases.Keys.Order(StringComparer.Ordinal)];

    /// <summary>Verifies the dispatcher gives the CoreCLR row for non-finite arguments: invalid before the source runs, vector rows and broadcast scalars alike.</summary>
    [Theory]
    [MemberData(nameof(NonFiniteCaseNames))]
    public void CUDADeviceDispatchGivesTheCoreCLRRowForNonFiniteArguments(string name)
    {
        ArgumentException.ThrowIfNullOrEmpty(name);
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var (identity, create, patches) = NonFiniteCases[name];
        RunDispatch(identity, create(), MathBlockCudaDeviceModule.DispatcherBlockSize, patches);
    }

    /// <summary>Gets each block-sized case with each block size; 0 stands for the device maximum.</summary>
    public static TheoryData<string, int> BlockSizedCaseNames
    {
        get
        {
            var data = new TheoryData<string, int>();
            foreach (var name in BlockSizedCases.Keys.Order(StringComparer.Ordinal))
                foreach (var blockSize in new[] { 1, 7, 32, 100, 129, 256, 0 })
                    data.Add(name, blockSize);
            return data;
        }
    }

    private static readonly Dictionary<string, (string Identity, Func<MathBlockValue[]> Inputs)> BlockSizedCases = new(StringComparer.Ordinal)
    {
        ["block-sized/unary-vector"] = ("elementwise.scalar.negate@1", () => [Vector(Enumerable.Range(0, 300).Select(index => index * 0.5d - 20d).ToArray()), Scalar(Fill)]),
        ["block-sized/rolling-median"] = ("sequence.rolling-median@1", () => [Vector(Enumerable.Range(0, 300).Select(index => (index * 37 % 101) * 0.5d - (index % 2 == 0 ? 0d : 0.25d)).ToArray()), Scalar(17d)]),
        ["block-sized/rolling-quantile"] = ("sequence.rolling-quantile@1", () => [Vector(Enumerable.Range(0, 300).Select(index => (index * 53 % 97) * 0.5d).ToArray()), Scalar(33d), Scalar(0.9d)]),
        ["block-sized/window-theil-sen"] = ("window.statistics.theil-sen-slope@1", () => WindowInputs("statistics.theil-sen-slope", 300, 17)),
        ["block-sized/window-median"] = ("window.vector.median@1", () => WindowInputs("vector.median", 300, 17)),
        ["block-sized/window-distance-correlation"] = ("window.statistics.distance-correlation@1", () => WindowInputs("statistics.distance-correlation", 300, 17)),
    };

    private static MathBlockValue[] WindowInputs(string source, int count, int width)
    {
        var series = MathBlockWindowTestSupport.CreateSourceInputs(source, count, width, 11);
        var unit = MathBlockWindowTestSupport.Form(source).ResolveOutputType(
            [.. series.Select(input => input.Type), MathBlockType.Scalar(), MathBlockType.Scalar()]).Unit;
        return MathBlockWindowTestSupport.FormInputs(series, width, MathBlockValue.Scalar(Fill, unit));
    }

    private static int DeviceMaximumThreadsPerBlock()
    {
        var native = typeof(MathBlocksCUDAWorker).Assembly.GetType("Supprocom.MathBlocks.Cuda.MathBlocksCudaNative", throwOnError: true)!;
        var limits = native.GetMethod("GetDeviceLimits")!.Invoke(null, null)!;
        return (int)limits.GetType().GetProperty("MaximumThreadsPerBlock")!.GetValue(limits)!;
    }

    // The launch and the resource lifetime stay in one visible path, as in the package-only consumer.
#pragma warning disable MA0051
    private static void RunDispatch(string identity, MathBlockValue[] inputs, int blockSize, (int Input, int Row, double Value)[]? patches = null)
    {
        var contract = MathBlockCudaDeviceModule.GetOperation(identity);
        Assert.True(contract.Opcode < 128, "The public opcode carries no mask.");
        var expected = patches is null ? contract.EvaluateCoreCLR(inputs) : PatchedExpected(identity, inputs, patches);
        var plan = contract.PlanCUDA(inputs, MathBlockDomainOptions.Default, blockSize);

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
        var scratchOffset = Allocate(ref cursor, plan.ScratchBytes);
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

            foreach (var (input, row, value) in patches ?? [])
            {
                if (row < 0)
                    Marshal.WriteInt64(host, input * MathBlockCudaSlotLayout.Size + MathBlockCudaSlotLayout.ScalarValueOffset, BitConverter.DoubleToInt64Bits(value));
                else
                    Marshal.WriteInt64(host, inputOffsets[input] + row * sizeof(double), BitConverter.DoubleToInt64Bits(value));
            }

            MathBlockCudaValueCodec.WriteHeader(
                host,
                inputs.Length * MathBlockCudaSlotLayout.Size,
                outputOffset < 0 ? 0ul : device + (ulong)outputOffset,
                scratchOffset < 0 ? 0ul : device + (ulong)scratchOffset,
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
                CudaDriver.cuLaunchKernel(function, 1, 1, 1, (uint)blockSize, 1, 1, 0, stream, parameterArray, IntPtr.Zero),
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

    // CoreCLR's result for the inputs with the patched rows: each row through the elementwise form's own row function. A form holds the fill
    // where the row is invalid and its sibling holds whether the row was computed.
    private static MathBlockValue PatchedExpected(string identity, MathBlockValue[] inputs, (int Input, int Row, double Value)[] patches)
    {
        var sibling = identity.StartsWith("elementwise-valid.", StringComparison.Ordinal);
        var source = identity[(identity.IndexOf('.', StringComparison.Ordinal) + 1)..identity.LastIndexOf('@')];
        var arity = MathBlockCatalog.Standard.Get(source).Arity;
        var columns = new double[arity][];
        for (var index = 0; index < arity; index++)
        {
            columns[index] = inputs[index].Type.Kind == MathBlockValueKind.Vector
                ? inputs[index].AsVector().ToArray()
                : [inputs[index].AsScalar()];
        }

        foreach (var (input, row, value) in patches)
            columns[input][row < 0 ? 0 : row] = value;
        var rows = columns.Where((_, index) => inputs[index].Type.Kind == MathBlockValueKind.Vector).First().Length;
        var values = new double[rows];
        var computed = new bool[rows];
        for (var row = 0; row < rows; row++)
        {
            var arguments = columns.Select((column, index) => column[inputs[index].Type.Kind == MathBlockValueKind.Vector ? row : 0]).ToArray();
            var (isComputed, value) = MathBlockElementwiseRowReference.Row(source, arguments);
            computed[row] = isComputed;
            values[row] = isComputed ? value : sibling ? 0d : inputs[arity].AsScalar();
        }

        return sibling ? MathBlockValue.BooleanVector(computed) : MathBlockValue.Vector(values);
    }

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
