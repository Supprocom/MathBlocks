namespace Supprocom.MathBlocks.Cuda;

internal static class GraphUndirectedShortestPathsV1BlockCuda
{
    internal const string Identity = "graph.undirected-shortest-paths@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Graph, 14);
}
