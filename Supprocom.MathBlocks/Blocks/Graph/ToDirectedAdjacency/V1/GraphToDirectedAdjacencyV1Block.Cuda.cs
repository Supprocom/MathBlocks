namespace Supprocom.MathBlocks.Cuda;

internal static class GraphToDirectedAdjacencyV1BlockCuda
{
    internal const string Identity = "graph.to-directed-adjacency@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Graph, 10);
}
