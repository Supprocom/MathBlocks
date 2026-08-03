namespace Supprocom.MathBlocks.Gpu;

internal static class GraphFromDirectedAdjacencyV1BlockGpu
{
    internal const string Identity = "graph.from-directed-adjacency@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Graph, 4);
}
