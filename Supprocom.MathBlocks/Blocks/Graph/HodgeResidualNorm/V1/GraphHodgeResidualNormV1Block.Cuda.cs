namespace Supprocom.MathBlocks.Cuda;

internal static class GraphHodgeResidualNormV1BlockCuda
{
    internal const string Identity = "graph.hodge-residual-norm@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Graph, 6);
}
