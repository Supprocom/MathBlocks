namespace Supprocom.MathBlocks.Gpu;

internal static class GraphPageRankV1BlockGpu
{
    internal const string Identity = "graph.page-rank@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Graph, 9);
}
