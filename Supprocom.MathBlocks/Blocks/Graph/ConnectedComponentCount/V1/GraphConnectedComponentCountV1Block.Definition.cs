namespace Supprocom.MathBlocks;
internal static partial class GraphMathBlocks
{
    internal static class GraphConnectedComponentCountV1Block
    {
        internal const string Identity = "graph.connected-component-count@1";
        internal static MathBlockOperation Create() => CreateScalar("graph.connected-component-count", graph => MathBlockGraphMath.ConnectedComponentCount(graph), path, 1d, DimensionlessGraphScalar);
    }
}
