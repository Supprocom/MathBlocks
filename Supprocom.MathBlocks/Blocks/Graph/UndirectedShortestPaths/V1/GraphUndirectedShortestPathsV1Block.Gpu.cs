namespace Supprocom.MathBlocks.Gpu;

internal static class GraphUndirectedShortestPathsV1BlockGpu
{
    internal const string Identity = "graph.undirected-shortest-paths@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Graph, 14);
}
