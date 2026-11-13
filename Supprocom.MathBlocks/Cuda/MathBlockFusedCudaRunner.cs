using System.Diagnostics;
using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks.Cuda;

// Runs fused-expression kernels on the current CUDA device: one NVRTC program holds the MathBlocks source and the
// given consumer source, and each case launches its expression's kernel once over all rows. Invalid inputs and
// invalid validity inputs are passed as zero-filled buffers.
internal static class MathBlockFusedCudaRunner
{
    // The launch-to-synchronize time of each case of the latest run, in milliseconds.
    public static IReadOnlyList<double> LaunchMilliseconds { get; private set; } = [];

    public static MathBlockFusedResult[] Run(
        string consumerSource,
        bool fusedMultiplyAdd,
        IReadOnlyList<MathBlockFusedExpression> expressions,
        IReadOnlyList<IReadOnlyDictionary<string, MathBlockValue>> inputs,
        IReadOnlyList<IReadOnlyDictionary<string, MathBlockValue>?> validity) =>
        RunWithOptions(consumerSource, fusedMultiplyAdd, expressions, inputs, validity, MathBlocksCudaOptions.Default);

    // The same run with the fused launch options: FusedBlockSize threads per block and at most FusedMaximumBlocks blocks.
    public static MathBlockFusedResult[] RunWithOptions(
        string consumerSource,
        bool fusedMultiplyAdd,
        IReadOnlyList<MathBlockFusedExpression> expressions,
        IReadOnlyList<IReadOnlyDictionary<string, MathBlockValue>> inputs,
        IReadOnlyList<IReadOnlyDictionary<string, MathBlockValue>?> validity,
        MathBlocksCudaOptions options)
    {
        MathBlocksCudaOptionsValidator.ValidateRanges(options);
        ArgumentException.ThrowIfNullOrWhiteSpace(consumerSource);
        ArgumentNullException.ThrowIfNull(expressions);
        ArgumentNullException.ThrowIfNull(inputs);
        ArgumentNullException.ThrowIfNull(validity);
        if (inputs.Count != expressions.Count || validity.Count != expressions.Count)
            throw new ArgumentException("Each case requires an expression, its inputs and its validity.", nameof(inputs));

        MathBlocksCudaOptionsValidator.ValidateDevice(options, MathBlocksCudaNative.GetDeviceLimits(options.DeviceOrdinal));
        var ptx = MathBlocksCudaNative.CompilePtx(
            MathBlockCudaDeviceModule.ComposeSource(consumerSource),
            "mathblocks-fused.cu",
            fusedMultiplyAdd,
            options.DeviceOrdinal);
        MathBlocksCudaNative.ThrowIfFailed(MathBlocksCudaNative.cuModuleLoadData(out var module, ptx), "cuModuleLoadData");
        try
        {
            var results = new MathBlockFusedResult[expressions.Count];
            var times = new double[expressions.Count];
            for (var index = 0; index < results.Length; index++)
                results[index] = RunCase(module, expressions[index], inputs[index], validity[index], options, out times[index]);
            LaunchMilliseconds = times;
            return results;
        }
        finally
        {
            _ = MathBlocksCudaNative.cuModuleUnload(module);
        }
    }

    private static MathBlockFusedResult RunCase(
        IntPtr module,
        MathBlockFusedExpression expression,
        IReadOnlyDictionary<string, MathBlockValue> inputs,
        IReadOnlyDictionary<string, MathBlockValue>? validity,
        MathBlocksCudaOptions options,
        out double launchMilliseconds)
    {
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(out var function, module, expression.CudaKernelName),
            "cuModuleGetFunction");
        MathBlocksCudaOptionsValidator.ValidateKernel(
            options.FusedBlockSize,
            MathBlocksCudaNative.GetKernelMaximumThreadsPerBlock(function),
            nameof(MathBlocksCudaOptions.FusedBlockSize),
            expression.CudaKernelName,
            "the fused-expression kernel");
        var program = expression.Program;
        var rows = 0;
        foreach (var name in expression.VectorInputNames)
            if (inputs[name] is { IsValid: true } value)
                rows = value.Type.Kind == MathBlockValueKind.Vector
                    ? value.AsVector().Count
                    : value.AsBooleanVector().Count;

        using var allocations = new DeviceAllocations();
        var inputPointers = new ulong[Math.Max(1, expression.VectorInputNames.Count)];
        var validityPointers = new ulong[inputPointers.Length];
        for (var ordinal = 0; ordinal < expression.VectorInputNames.Count; ordinal++)
        {
            var name = expression.VectorInputNames[ordinal];
            var value = inputs[name];
            inputPointers[ordinal] = program.Inputs[name].Kind == MathBlockValueKind.Vector
                ? allocations.Upload(value.IsValid ? value.AsVector().ToArray() : new double[rows])
                : allocations.Upload(ToFlags(value, rows));
            if (validity is not null && validity.TryGetValue(name, out var rowValidity))
                validityPointers[ordinal] = allocations.Upload(ToFlags(rowValidity, rows));
        }

        var scalars = new double[Math.Max(1, expression.ScalarInputNames.Count)];
        for (var ordinal = 0; ordinal < expression.ScalarInputNames.Count; ordinal++)
            if (inputs[expression.ScalarInputNames[ordinal]] is { IsValid: true } scalar)
                scalars[ordinal] = scalar.AsScalar();

        var outputCount = expression.OutputNames.Count;
        var outputPointers = new ulong[outputCount];
        var outputValidityPointers = new ulong[outputCount];
        for (var index = 0; index < outputCount; index++)
        {
            var isNumber = program.Outputs[expression.OutputNames[index]].Kind == MathBlockValueKind.Vector;
            outputPointers[index] = allocations.Allocate(checked(rows * (isNumber ? sizeof(double) : sizeof(int))));
            outputValidityPointers[index] = allocations.Allocate(checked(rows * sizeof(int)));
        }

        var inputTable = allocations.Upload(inputPointers);
        var validityTable = allocations.Upload(validityPointers);
        var scalarTable = allocations.Upload(scalars);
        var outputTable = allocations.Upload(outputPointers);
        var outputValidityTable = allocations.Upload(outputValidityPointers);
        var mask = allocations.Upload(new ulong[1]);
        var rowCount = (long)rows;
        var wantedBlocks = rows > 0 ? ((long)rows + options.FusedBlockSize - 1L) / options.FusedBlockSize : 0L;
        var blocks = Math.Min(options.FusedMaximumBlocks, wantedBlocks);
        var watch = Stopwatch.StartNew();
        if (rows > 0)
            Launch(function, (uint)blocks, options.FusedBlockSize, inputTable, scalarTable, validityTable, rowCount, outputTable, outputValidityTable, mask);
        launchMilliseconds = watch.Elapsed.TotalMilliseconds;

        var outputs = new Array[outputCount];
        var validityOutputs = new int[outputCount][];
        for (var index = 0; index < outputCount; index++)
        {
            outputs[index] = program.Outputs[expression.OutputNames[index]].Kind == MathBlockValueKind.Vector
                ? Download<double>(outputPointers[index], rows)
                : Download<int>(outputPointers[index], rows);
            validityOutputs[index] = Download<int>(outputValidityPointers[index], rows);
        }
        var invalidMask = Download<ulong>(mask, 1)[0];
        var result = expression.CreateCudaResult(inputs, validity, outputs, validityOutputs, invalidMask);
        result.Launch = new MathBlockCudaLaunch(
            expression.CudaKernelName,
            null,
            (int)blocks,
            options.FusedBlockSize,
            0L,
            wantedBlocks,
            blocks < wantedBlocks ? nameof(MathBlocksCudaOptions.FusedMaximumBlocks) : null);
        return result;
    }

    private static unsafe void Launch(
        IntPtr function,
        uint blocks,
        int blockSize,
        ulong inputTable,
        ulong scalarTable,
        ulong validityTable,
        long rowCount,
        ulong outputTable,
        ulong outputValidityTable,
        ulong mask)
    {
        var parameters = stackalloc IntPtr[7];
        parameters[0] = (IntPtr)(&inputTable);
        parameters[1] = (IntPtr)(&scalarTable);
        parameters[2] = (IntPtr)(&validityTable);
        parameters[3] = (IntPtr)(&rowCount);
        parameters[4] = (IntPtr)(&outputTable);
        parameters[5] = (IntPtr)(&outputValidityTable);
        parameters[6] = (IntPtr)(&mask);
        MathBlocksCudaNative.ThrowIfFailed(
            NativeMethods.cuLaunchKernel(
                function, blocks, 1, 1, (uint)blockSize, 1, 1, 0, IntPtr.Zero, (IntPtr)parameters, IntPtr.Zero),
            "cuLaunchKernel");
        MathBlocksCudaNative.ThrowIfFailed(NativeMethods.cuCtxSynchronize(), "cuCtxSynchronize");
    }

    private static int[] ToFlags(MathBlockValue value, int rows)
    {
        var flags = new int[rows];
        if (value.IsValid)
        {
            var source = value.AsBooleanVector();
            for (var row = 0; row < rows; row++)
                flags[row] = source[row] ? 1 : 0;
        }
        return flags;
    }

    private static unsafe T[] Download<T>(ulong pointer, int count) where T : unmanaged
    {
        var result = new T[count];
        if (count == 0)
            return result;
        fixed (T* destination = result)
            MathBlocksCudaNative.ThrowIfFailed(
                NativeMethods.cuMemcpyDtoH((IntPtr)destination, pointer, (UIntPtr)(uint)(count * sizeof(T))),
                "cuMemcpyDtoH");
        return result;
    }

    private sealed class DeviceAllocations : IDisposable
    {
        private readonly List<ulong> pointers = [];

        public ulong Allocate(int bytes)
        {
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuMemAlloc(out var pointer, (UIntPtr)(uint)Math.Max(bytes, 8)),
                "cuMemAlloc");
            pointers.Add(pointer);
            return pointer;
        }

        public unsafe ulong Upload<T>(T[] values) where T : unmanaged
        {
            var bytes = checked(values.Length * sizeof(T));
            var pointer = Allocate(bytes);
            if (bytes == 0)
                return pointer;
            fixed (T* source = values)
                MathBlocksCudaNative.ThrowIfFailed(
                    MathBlocksCudaNative.cuMemcpyHtoD(pointer, (IntPtr)source, (UIntPtr)(uint)bytes),
                    "cuMemcpyHtoD");
            return pointer;
        }

        public void Dispose()
        {
            for (var index = 0; index < pointers.Count; index++)
                _ = MathBlocksCudaNative.cuMemFree(pointers[index]);
            pointers.Clear();
        }
    }

    private static class NativeMethods
    {
        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
        internal static extern int cuLaunchKernel(
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

        [DllImport("nvcuda.dll", EntryPoint = "cuMemcpyDtoH_v2", CallingConvention = CallingConvention.Cdecl)]
        internal static extern int cuMemcpyDtoH(IntPtr destination, ulong source, UIntPtr bytes);

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
        internal static extern int cuCtxSynchronize();
    }
}
