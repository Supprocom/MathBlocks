namespace Supprocom.MathBlocks.Gpu;

internal static class GraphUndirectedLaplacianV1BlockGpu
{
    internal const string Identity = "graph.undirected-laplacian@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Graph, 13);
}
