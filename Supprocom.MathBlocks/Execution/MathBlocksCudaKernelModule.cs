using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks.Cuda;

internal static class MathBlocksCudaKernelModule
{
    private static readonly Lazy<ModuleState> state = new(Load, LazyThreadSafetyMode.ExecutionAndPublication);

    public static IReadOnlyCollection<string> SupportedBlockIdentities { get; } =
        MathBlockCudaFeatureIndex.SupportedIdentities;

    public static KernelBinding Resolve(string identity)
    {
        var feature = MathBlockCudaFeatureIndex.Resolve(identity);
        return feature.Family switch
        {
            MathBlockCudaFamily.Scalar => new KernelBinding(state.Value.ScalarFunction, feature.Opcode, 1),
            MathBlockCudaFamily.Vector => new KernelBinding(
                state.Value.VectorFunction, feature.Opcode, VectorCudaBlockCatalog.BlockSize),
            MathBlockCudaFamily.Complex => new KernelBinding(
                state.Value.ComplexFunction, feature.Opcode, ComplexCudaBlockCatalog.BlockSize),
            MathBlockCudaFamily.Matrix => new KernelBinding(
                state.Value.MatrixFunction, feature.Opcode, MatrixCudaBlockCatalog.BlockSize),
            MathBlockCudaFamily.Probability => new KernelBinding(
                state.Value.ProbabilityFunction, feature.Opcode, ProbabilityCudaBlockCatalog.BlockSize),
            MathBlockCudaFamily.SequencePath => new KernelBinding(
                state.Value.SequencePathFunction, feature.Opcode, SequencePathCudaBlockCatalog.BlockSize),
            MathBlockCudaFamily.Statistics => new KernelBinding(
                state.Value.StatisticsFunction, feature.Opcode, StatisticsCudaBlockCatalog.BlockSize),
            MathBlockCudaFamily.Geometry => new KernelBinding(
                state.Value.GeometryFunction, feature.Opcode, GeometryCudaBlockCatalog.BlockSize),
            MathBlockCudaFamily.Graph => new KernelBinding(
                state.Value.GraphFunction, feature.Opcode, GraphCudaBlockCatalog.BlockSize),
            MathBlockCudaFamily.Advanced => new KernelBinding(
                state.Value.AdvancedFunction, feature.Opcode, AdvancedCudaBlockCatalog.BlockSize),
            MathBlockCudaFamily.Transport => new KernelBinding(
                state.Value.TransportFunction, feature.Opcode, TransportCudaBlockCatalog.BlockSize),
            _ => throw new InvalidOperationException($"CUDA family '{feature.Family}' is not supported.")
        };
    }

    private static ModuleState Load()
    {
        var source = MathBlockCudaDeviceModule.Source;
        var ptx = MathBlocksCudaNative.CompilePtx(source, "mathblocks.cu");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleLoadData(out var module, ptx),
            "cuModuleLoadData(mathblocks)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var scalarFunction,
                module,
                ScalarCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_scalar)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var vectorFunction,
                module,
                VectorCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_vector)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var complexFunction,
                module,
                ComplexCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_complex)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var matrixFunction,
                module,
                MatrixCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_matrix)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var probabilityFunction,
                module,
                ProbabilityCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_probability)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var sequencePathFunction,
                module,
                SequencePathCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_sequence_path)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var statisticsFunction,
                module,
                StatisticsCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_statistics)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var geometryFunction,
                module,
                GeometryCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_geometry)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var graphFunction,
                module,
                GraphCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_graph)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var advancedFunction,
                module,
                AdvancedCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_advanced)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var transportFunction,
                module,
                TransportCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_transport)");
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
            transportFunction);
    }

    [StructLayout(LayoutKind.Sequential)]
    public readonly record struct KernelBinding(IntPtr Function, int Opcode, uint BlockX);
    private sealed record ModuleState(
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
        IntPtr TransportFunction);
}
