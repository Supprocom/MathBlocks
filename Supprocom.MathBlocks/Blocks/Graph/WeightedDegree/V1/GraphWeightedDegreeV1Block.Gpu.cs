namespace Supprocom.MathBlocks.Gpu;

internal static class GraphWeightedDegreeV1BlockGpu
{
    internal const string Identity = "graph.weighted-degree@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Graph, 15);
}
