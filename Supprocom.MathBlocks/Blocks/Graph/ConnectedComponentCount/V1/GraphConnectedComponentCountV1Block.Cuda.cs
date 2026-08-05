namespace Supprocom.MathBlocks.Cuda;

internal static class GraphConnectedComponentCountV1BlockCuda
{
    internal const string Identity = "graph.connected-component-count@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Graph, 2);
}
