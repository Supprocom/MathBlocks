using System.Reflection;
using System.Runtime.InteropServices;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

// The CUDA type-rule module resolves the same output types as the host. The device runs this; without one it fails at its first line like the
// other CUDA tests.
public sealed partial class MathBlockCudaWorkerTests
{
    private const int TypeRuleCasesPerOperation = 1_200;

    [StructLayout(LayoutKind.Sequential)]
    private struct TypeRuleDeviceType
    {
        public int Kind;
        public int Rows;
        public int Columns;
        public int Numerator0;
        public int Numerator1;
        public int Numerator2;
        public int Numerator3;
        public int Denominator0;
        public int Denominator1;
        public int Denominator2;
        public int Denominator3;
    }

    /// <summary>Verifies the CUDA type-rule resolver agrees with the host resolver, and with the legacy delegate, on the grid of kinds, shapes and units of every signed operation.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    [Trait("Category", "TypeSignature")]
    public void CUDATypeRuleResolverEqualsTheHostResolverOnTheGrid()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var kernel = string.Join(
            "\n",
            "",
            "extern \"C\" __global__ void mathblocks_type_resolve_grid(",
            "    const int* rows, const int* rowOffsets, const MathBlockDeviceType* inputs, const int* inputStarts,",
            "    const int* counts, MathBlockDeviceType* outputs, int caseCount)",
            "{",
            "    for (int index = blockIdx.x * blockDim.x + threadIdx.x; index < caseCount; index += gridDim.x * blockDim.x)",
            "        mathblocks_type_resolve(rows + rowOffsets[index], inputs + inputStarts[index], counts[index], &outputs[index]);",
            "}",
            "");
        MathBlockTypeSignatures.WriteTable(out var offsets, out var tableRows);
        var operations = MathBlockCatalog.Standard.Operations;
        var rowOffsets = new List<int>();
        var inputStarts = new List<int>();
        var counts = new List<int>();
        var inputs = new List<TypeRuleDeviceType>();
        var expected = new List<(string Identity, MathBlockType[] Types, MathBlockType? Type)>();
        for (var index = 0; index < operations.Count; index++)
        {
            if (offsets[index] < 0)
                continue;
            var signature = operations[index].TypeSignature!;
            var taken = 0;
            foreach (var types in MathBlockTypeSignatureGrid.Cases(operations[index]))
            {
                if (taken++ >= TypeRuleCasesPerOperation)
                    break;
                rowOffsets.Add(offsets[index]);
                inputStarts.Add(inputs.Count);
                counts.Add(types.Length);
                foreach (var type in types)
                    inputs.Add(ToDeviceType(type));
                if (inputs.Count == inputStarts[^1])
                    inputs.Add(default);
                expected.Add((operations[index].Identity, types, MathBlockTypeSignatures.TryResolve(signature, types, out var output) ? output : null));
            }
        }

        var ptx = MathBlockCudaDeviceModule.CompilePtx(MathBlockCudaTypeRuleModule.Source + kernel, "mathblocks-type-rule-grid.cu");
        var actual = TypeRuleDevice.Run(ptx, tableRows, [.. rowOffsets], [.. inputs], [.. inputStarts], [.. counts]);

        var failures = new List<string>();
        for (var index = 0; index < expected.Count; index++)
        {
            var device = actual[index];
            var host = expected[index].Type;
            var same = host is { } type
                ? device.Kind == (int)type.Kind && device.Rows == type.Rows && device.Columns == type.Columns &&
                  FromDeviceUnit(device) == type.Unit
                : device.Kind == -1;
            if (!same)
                failures.Add($"{expected[index].Identity}: host {(host is { } t ? t.ToString() : "invalid")}, CUDA kind {device.Kind} rows {device.Rows} for {string.Join(" ; ", expected[index].Types)}");
        }

        Assert.True(failures.Count == 0, $"{failures.Count} of {expected.Count} cases differ. {string.Join(Environment.NewLine, failures.Take(40))}");
        Assert.True(expected.Count >= TypeRuleCasesPerOperation * offsets.Count(offset => offset >= 0), $"Only {expected.Count} cases ran.");
    }

    private static TypeRuleDeviceType ToDeviceType(MathBlockType type) => new()
    {
        Kind = (int)type.Kind,
        Rows = type.Rows,
        Columns = type.Columns,
        Numerator0 = type.Unit.Dimension0.Numerator,
        Numerator1 = type.Unit.Dimension1.Numerator,
        Numerator2 = type.Unit.Dimension2.Numerator,
        Numerator3 = type.Unit.Dimension3.Numerator,
        Denominator0 = type.Unit.Dimension0.Denominator,
        Denominator1 = type.Unit.Dimension1.Denominator,
        Denominator2 = type.Unit.Dimension2.Denominator,
        Denominator3 = type.Unit.Dimension3.Denominator
    };

    private static MathBlockUnit FromDeviceUnit(TypeRuleDeviceType value) => new(
        new MathRational(value.Numerator0, value.Denominator0),
        new MathRational(value.Numerator1, value.Denominator1),
        new MathRational(value.Numerator2, value.Denominator2),
        new MathRational(value.Numerator3, value.Denominator3));

    // A minimal driver-API runner for the one grid kernel.
    private static class TypeRuleDevice
    {
        private static readonly bool ResolverSet = Register();

        internal static TypeRuleDeviceType[] Run(byte[] ptx, int[] rows, int[] rowOffsets, TypeRuleDeviceType[] inputs, int[] inputStarts, int[] counts)
        {
            _ = ResolverSet;
            typeof(MathBlockCatalog).Assembly
                .GetType("Supprocom.MathBlocks.Cuda.MathBlocksCudaNative", throwOnError: true)!
                .GetMethod("EnsureContext", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic)!
                .Invoke(null, [0]);
            Check(cuModuleLoadData(out var module, ptx), "cuModuleLoadData");
            Check(cuModuleGetFunction(out var function, module, "mathblocks_type_resolve_grid\0"u8.ToArray()), "cuModuleGetFunction");
            var caseCount = counts.Length;
            var outputs = new TypeRuleDeviceType[caseCount];
            var buffers = new ulong[6];
            var argumentValues = Marshal.AllocHGlobal(7 * sizeof(long));
            var argumentPointers = Marshal.AllocHGlobal(7 * IntPtr.Size);
            try
            {
                buffers[0] = Upload(rows);
                buffers[1] = Upload(rowOffsets);
                buffers[2] = Upload(inputs);
                buffers[3] = Upload(inputStarts);
                buffers[4] = Upload(counts);
                buffers[5] = Upload(outputs);
                for (var index = 0; index < 6; index++)
                    Marshal.WriteInt64(argumentValues, index * sizeof(long), unchecked((long)buffers[index]));
                Marshal.WriteInt32(argumentValues, 6 * sizeof(long), caseCount);
                for (var index = 0; index < 7; index++)
                    Marshal.WriteIntPtr(argumentPointers, index * IntPtr.Size, argumentValues + (index * sizeof(long)));
                Check(cuLaunchKernel(function, 64, 1, 1, 128, 1, 1, 0, IntPtr.Zero, argumentPointers, IntPtr.Zero), "cuLaunchKernel");
                Check(cuCtxSynchronize(), "cuCtxSynchronize");
                var outputHandle = GCHandle.Alloc(outputs, GCHandleType.Pinned);
                try
                {
                    Check(cuMemcpyDtoH(outputHandle.AddrOfPinnedObject(), buffers[5], new UIntPtr(checked((ulong)caseCount * (ulong)Marshal.SizeOf<TypeRuleDeviceType>()))), "cuMemcpyDtoH");
                }
                finally
                {
                    outputHandle.Free();
                }
            }
            finally
            {
                Marshal.FreeHGlobal(argumentPointers);
                Marshal.FreeHGlobal(argumentValues);
                for (var index = 0; index < buffers.Length; index++)
                {
                    if (buffers[index] != 0)
                        _ = cuMemFree(buffers[index]);
                }

                _ = cuModuleUnload(module);
            }

            return outputs;
        }

        private static ulong Upload<T>(T[] data)
            where T : unmanaged
        {
            var bytes = new UIntPtr(checked((ulong)Math.Max(1, data.Length * Marshal.SizeOf<T>())));
            Check(cuMemAlloc(out var pointer, bytes), "cuMemAlloc");
            var handle = GCHandle.Alloc(data, GCHandleType.Pinned);
            try
            {
                Check(cuMemcpyHtoD(pointer, handle.AddrOfPinnedObject(), bytes), "cuMemcpyHtoD");
            }
            finally
            {
                handle.Free();
            }

            return pointer;
        }

        private static void Check(int result, string call)
        {
            if (result != 0)
                throw new InvalidOperationException($"{call} failed with CUDA driver error {result}.");
        }

        private static bool Register()
        {
            MathBlockCudaTestDriverResolver.Register();
            return true;
        }

        [DllImport("nvcuda.dll")]
        private static extern int cuModuleLoadData(out IntPtr module, byte[] image);

        [DllImport("nvcuda.dll")]
        private static extern int cuModuleGetFunction(out IntPtr function, IntPtr module, byte[] name);

        [DllImport("nvcuda.dll")]
        private static extern int cuModuleUnload(IntPtr module);

        [DllImport("nvcuda.dll", EntryPoint = "cuMemAlloc_v2")]
        private static extern int cuMemAlloc(out ulong pointer, UIntPtr bytes);

        [DllImport("nvcuda.dll", EntryPoint = "cuMemFree_v2")]
        private static extern int cuMemFree(ulong pointer);

        [DllImport("nvcuda.dll", EntryPoint = "cuMemcpyHtoD_v2")]
        private static extern int cuMemcpyHtoD(ulong destination, IntPtr source, UIntPtr bytes);

        [DllImport("nvcuda.dll", EntryPoint = "cuMemcpyDtoH_v2")]
        private static extern int cuMemcpyDtoH(IntPtr destination, ulong source, UIntPtr bytes);

        [DllImport("nvcuda.dll")]
        private static extern int cuLaunchKernel(
            IntPtr function, uint gridX, uint gridY, uint gridZ, uint blockX, uint blockY, uint blockZ,
            uint sharedMemoryBytes, IntPtr stream, IntPtr kernelParameters, IntPtr extra);

        [DllImport("nvcuda.dll")]
        private static extern int cuCtxSynchronize();
    }
}
