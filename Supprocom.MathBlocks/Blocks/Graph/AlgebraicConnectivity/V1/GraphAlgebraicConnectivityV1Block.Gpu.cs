namespace Supprocom.MathBlocks.Gpu;

internal static class GraphAlgebraicConnectivityV1BlockGpu
{
    internal const string Identity = "graph.algebraic-connectivity@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Graph, 0);
}
