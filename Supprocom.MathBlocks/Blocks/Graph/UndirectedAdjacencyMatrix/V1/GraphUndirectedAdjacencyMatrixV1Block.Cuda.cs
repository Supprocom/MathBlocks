namespace Supprocom.MathBlocks.Cuda;

internal static class GraphUndirectedAdjacencyMatrixV1BlockCuda
{
    internal const string Identity = "graph.undirected-adjacency-matrix@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Graph, 12);
}
