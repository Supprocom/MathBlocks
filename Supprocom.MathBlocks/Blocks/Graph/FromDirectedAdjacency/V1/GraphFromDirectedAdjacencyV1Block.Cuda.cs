namespace Supprocom.MathBlocks.Cuda;

internal static class GraphFromDirectedAdjacencyV1BlockCuda
{
    internal const string Identity = "graph.from-directed-adjacency@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Graph, 4);
}
