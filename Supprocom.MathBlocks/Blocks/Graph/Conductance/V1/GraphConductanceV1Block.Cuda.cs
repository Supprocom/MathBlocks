namespace Supprocom.MathBlocks.Cuda;

internal static class GraphConductanceV1BlockCuda
{
    internal const string Identity = "graph.conductance@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Graph, 1);
}
