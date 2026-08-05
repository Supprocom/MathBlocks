namespace Supprocom.MathBlocks.Cuda;

internal static class GraphWeightedDegreeV1BlockCuda
{
    internal const string Identity = "graph.weighted-degree@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Graph, 15);
}
