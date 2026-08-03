namespace Supprocom.MathBlocks.Gpu;

internal static class GraphTriangleCountV1BlockGpu
{
    internal const string Identity = "graph.triangle-count@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Graph, 11);
}
