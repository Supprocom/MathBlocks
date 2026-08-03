namespace Supprocom.MathBlocks.Gpu;

internal static class GraphUndirectedAdjacencyMatrixV1BlockGpu
{
    internal const string Identity = "graph.undirected-adjacency-matrix@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Graph, 12);
}
