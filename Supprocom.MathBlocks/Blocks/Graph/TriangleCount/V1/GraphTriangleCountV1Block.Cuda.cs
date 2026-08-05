namespace Supprocom.MathBlocks.Cuda;

internal static class GraphTriangleCountV1BlockCuda
{
    internal const string Identity = "graph.triangle-count@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Graph, 11);
}
