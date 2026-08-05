namespace Supprocom.MathBlocks.Cuda;

internal static class GraphHodgePotentialV1BlockCuda
{
    internal const string Identity = "graph.hodge-potential@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Graph, 5);
}
