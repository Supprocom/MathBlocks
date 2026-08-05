namespace Supprocom.MathBlocks.Cuda;

internal static class GraphUndirectedLaplacianV1BlockCuda
{
    internal const string Identity = "graph.undirected-laplacian@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Graph, 13);
}
