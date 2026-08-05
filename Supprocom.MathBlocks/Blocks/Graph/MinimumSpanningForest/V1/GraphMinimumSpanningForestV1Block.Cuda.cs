namespace Supprocom.MathBlocks.Cuda;

internal static class GraphMinimumSpanningForestV1BlockCuda
{
    internal const string Identity = "graph.minimum-spanning-forest@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Graph, 8);
}
