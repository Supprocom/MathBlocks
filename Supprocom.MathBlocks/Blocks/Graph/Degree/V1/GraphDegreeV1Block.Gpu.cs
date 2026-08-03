namespace Supprocom.MathBlocks.Gpu;

internal static class GraphDegreeV1BlockGpu
{
    internal const string Identity = "graph.degree@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Graph, 3);
}
