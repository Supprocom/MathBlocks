namespace Supprocom.MathBlocks.Gpu;

internal static class GraphConductanceV1BlockGpu
{
    internal const string Identity = "graph.conductance@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Graph, 1);
}
