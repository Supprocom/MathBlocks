using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks.Cuda;

internal static class MathBlocksCudaKernelModule
{
    // One module per device ordinal and domain option set: the domain limits are in the device source.
    private static readonly System.Collections.Concurrent.ConcurrentDictionary<string, Lazy<ModuleState>> states = new(StringComparer.Ordinal);

    public static IReadOnlyCollection<string> SupportedBlockIdentities { get; } =
        MathBlockCudaFeatureIndex.SupportedIdentities;

    public static KernelBinding Resolve(string identity) => Resolve(identity, (int)VectorCudaBlockCatalog.BlockSize);

    public static KernelBinding Resolve(string identity, int blockSize) =>
        Resolve(identity, blockSize, 0, MathBlockDomainOptions.Default);

    // The module of a device and domain option set, loaded once.
    public static ModuleState GetState(int ordinal, MathBlockDomainOptions domainOptions)
    {
        var key = string.Create(
            System.Globalization.CultureInfo.InvariantCulture,
            $"{ordinal}\n{MathBlockCudaDevicePrelude.Create(domainOptions, MathBlockCudaDeviceModule.OperationIdentities)}");
        return states.GetOrAdd(
            key,
            static (_, device) => new Lazy<ModuleState>(() => Load(device.Ordinal, device.Domain), LazyThreadSafetyMode.ExecutionAndPublication),
            (Ordinal: ordinal, Domain: domainOptions)).Value;
    }

    // The binding of an operation for a launch of blockSize threads per block; the scalar family always runs one thread.
    public static KernelBinding Resolve(string identity, int blockSize, int ordinal, MathBlockDomainOptions domainOptions)
    {
        var state = GetState(ordinal, domainOptions);
        var block = (uint)blockSize;
        var feature = MathBlockCudaFeatureIndex.Resolve(identity);
        return feature.Family switch
        {
            MathBlockCudaFamily.Scalar => new KernelBinding(state.ScalarFunction, feature.Opcode, 1),
            MathBlockCudaFamily.Vector => new KernelBinding(
                state.VectorFunction, feature.Opcode, block),
            MathBlockCudaFamily.Complex => new KernelBinding(
                state.ComplexFunction, feature.Opcode, block),
            MathBlockCudaFamily.Matrix => new KernelBinding(
                state.MatrixFunction, feature.Opcode, block),
            MathBlockCudaFamily.Probability => new KernelBinding(
                state.ProbabilityFunction, feature.Opcode, block),
            MathBlockCudaFamily.SequencePath => new KernelBinding(
                state.SequencePathFunction, feature.Opcode, block),
            MathBlockCudaFamily.Statistics => new KernelBinding(
                state.StatisticsFunction, feature.Opcode, block),
            MathBlockCudaFamily.Geometry => new KernelBinding(
                state.GeometryFunction, feature.Opcode, block),
            MathBlockCudaFamily.Graph => new KernelBinding(
                state.GraphFunction, feature.Opcode, block),
            MathBlockCudaFamily.Advanced => new KernelBinding(
                state.AdvancedFunction, feature.Opcode, block),
            MathBlockCudaFamily.Transport => new KernelBinding(
                state.TransportFunction, feature.Opcode, block),
            MathBlockCudaFamily.Window => new KernelBinding(
                state.WindowFunction, feature.Opcode, block, RowStriped: true,
                ScratchCapacityArgument: true),
            MathBlockCudaFamily.Elementwise => new KernelBinding(
                state.ElementwiseFunction, feature.Opcode, block, RowStriped: true),
            _ => throw new InvalidOperationException($"CUDA family '{feature.Family}' is not supported.")
        };
    }

    private static ModuleState Load(int ordinal, MathBlockDomainOptions domainOptions)
    {
        var source = MathBlockCudaDeviceModule.GetSource(domainOptions);
        var ptx = MathBlocksCudaNative.CompilePtx(source, "mathblocks.cu", ordinal);
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleLoadData(out var module, ptx),
            "cuModuleLoadData(mathblocks)");
        var scalarFunction = GetFunction(module, ScalarCudaBlockCatalog.KernelEntryPoint, "cuModuleGetFunction(mathblocks_scalar)");
        var vectorFunction = GetFunction(module, VectorCudaBlockCatalog.KernelEntryPoint, "cuModuleGetFunction(mathblocks_vector)");
        var complexFunction = GetFunction(module, ComplexCudaBlockCatalog.KernelEntryPoint, "cuModuleGetFunction(mathblocks_complex)");
        var matrixFunction = GetFunction(module, MatrixCudaBlockCatalog.KernelEntryPoint, "cuModuleGetFunction(mathblocks_matrix)");
        var probabilityFunction = GetFunction(module, ProbabilityCudaBlockCatalog.KernelEntryPoint, "cuModuleGetFunction(mathblocks_probability)");
        var sequencePathFunction = GetFunction(module, SequencePathCudaBlockCatalog.KernelEntryPoint, "cuModuleGetFunction(mathblocks_sequence_path)");
        var statisticsFunction = GetFunction(module, StatisticsCudaBlockCatalog.KernelEntryPoint, "cuModuleGetFunction(mathblocks_statistics)");
        var geometryFunction = GetFunction(module, GeometryCudaBlockCatalog.KernelEntryPoint, "cuModuleGetFunction(mathblocks_geometry)");
        var graphFunction = GetFunction(module, GraphCudaBlockCatalog.KernelEntryPoint, "cuModuleGetFunction(mathblocks_graph)");
        var advancedFunction = GetFunction(module, AdvancedCudaBlockCatalog.KernelEntryPoint, "cuModuleGetFunction(mathblocks_advanced)");
        var transportFunction = GetFunction(module, TransportCudaBlockCatalog.KernelEntryPoint, "cuModuleGetFunction(mathblocks_transport)");
        var windowFunction = GetFunction(module, WindowCudaBlockCatalog.KernelEntryPoint, "cuModuleGetFunction(mathblocks_window)");
        var elementwiseFunction = GetFunction(module, ElementwiseCudaBlockCatalog.KernelEntryPoint, "cuModuleGetFunction(mathblocks_elementwise)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetGlobal(
                out var countsPointer,
                out var countsBytes,
                module,
                MathBlockCudaDeviceModule.NonConvergenceCountsSymbol),
            "cuModuleGetGlobal(mathblocks_nonconvergence_counts)");
        return new ModuleState(
            module,
            scalarFunction,
            vectorFunction,
            complexFunction,
            matrixFunction,
            probabilityFunction,
            sequencePathFunction,
            statisticsFunction,
            geometryFunction,
            graphFunction,
            advancedFunction,
            transportFunction,
            windowFunction,
            elementwiseFunction,
            countsPointer,
            checked((int)countsBytes));
    }

    private static IntPtr GetFunction(IntPtr module, string entryPoint, string operation)
    {
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(out var function, module, entryPoint),
            operation);
        return function;
    }

    // A row-striped kernel (the window and elementwise families) takes its grid from the plan; the window kernel
    // also takes a fifth argument, the scratch doubles per thread. Every other kernel runs one block with four
    // arguments.
    [StructLayout(LayoutKind.Sequential)]
    public readonly record struct KernelBinding(
        IntPtr Function,
        int Opcode,
        uint BlockX,
        bool RowStriped = false,
        bool ScratchCapacityArgument = false);
    // CountsPointer and CountsBytes are the non-convergence counters (MathBlockCudaDeviceModule.NonConvergenceCountsSymbol) of the
    // module. CountsLock orders the zeroing, the launch and the read of one execution against another program's on this module.
    internal sealed record ModuleState(
        IntPtr Module,
        IntPtr ScalarFunction,
        IntPtr VectorFunction,
        IntPtr ComplexFunction,
        IntPtr MatrixFunction,
        IntPtr ProbabilityFunction,
        IntPtr SequencePathFunction,
        IntPtr StatisticsFunction,
        IntPtr GeometryFunction,
        IntPtr GraphFunction,
        IntPtr AdvancedFunction,
        IntPtr TransportFunction,
        IntPtr WindowFunction,
        IntPtr ElementwiseFunction,
        ulong CountsPointer,
        int CountsBytes)
    {
        public Lock CountsLock { get; } = new();
    }
}
