namespace Supprocom.MathBlocks.Cuda;

internal static class GraphPageRankV1BlockCuda
{
    internal const string Identity = "graph.page-rank@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Graph, 9);
}
