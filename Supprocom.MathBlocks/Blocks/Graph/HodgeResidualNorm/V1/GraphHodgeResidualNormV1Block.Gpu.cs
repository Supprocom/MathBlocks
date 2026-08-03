namespace Supprocom.MathBlocks.Gpu;

internal static class GraphHodgeResidualNormV1BlockGpu
{
    internal const string Identity = "graph.hodge-residual-norm@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Graph, 6);
}
