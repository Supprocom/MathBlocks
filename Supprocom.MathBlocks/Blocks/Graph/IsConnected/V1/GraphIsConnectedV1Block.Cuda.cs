namespace Supprocom.MathBlocks.Cuda;

internal static class GraphIsConnectedV1BlockCuda
{
    internal const string Identity = "graph.is-connected@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Graph, 7);
}
