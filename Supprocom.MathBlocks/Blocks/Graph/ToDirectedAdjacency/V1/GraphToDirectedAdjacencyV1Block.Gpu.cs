namespace Supprocom.MathBlocks.Gpu;

internal static class GraphToDirectedAdjacencyV1BlockGpu
{
    internal const string Identity = "graph.to-directed-adjacency@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Graph, 10);
}
