namespace Supprocom.MathBlocks.Gpu;

internal static class GraphMinimumSpanningForestV1BlockGpu
{
    internal const string Identity = "graph.minimum-spanning-forest@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Graph, 8);
}
