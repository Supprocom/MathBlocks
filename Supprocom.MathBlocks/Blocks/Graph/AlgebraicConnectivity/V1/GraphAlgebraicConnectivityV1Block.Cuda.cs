namespace Supprocom.MathBlocks.Cuda;

internal static class GraphAlgebraicConnectivityV1BlockCuda
{
    internal const string Identity = "graph.algebraic-connectivity@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Graph, 0);
}
