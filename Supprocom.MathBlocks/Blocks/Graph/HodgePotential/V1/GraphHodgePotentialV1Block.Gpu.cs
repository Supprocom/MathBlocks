namespace Supprocom.MathBlocks.Gpu;

internal static class GraphHodgePotentialV1BlockGpu
{
    internal const string Identity = "graph.hodge-potential@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Graph, 5);
}
