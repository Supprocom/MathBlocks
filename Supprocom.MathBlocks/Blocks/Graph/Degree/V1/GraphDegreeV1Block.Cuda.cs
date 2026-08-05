namespace Supprocom.MathBlocks.Cuda;

internal static class GraphDegreeV1BlockCuda
{
    internal const string Identity = "graph.degree@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Graph, 3);
}
