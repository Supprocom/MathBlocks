namespace Supprocom.MathBlocks;
internal static partial class GraphMathBlocks
{
    internal static class GraphTriangleCountV1Block
    {
        internal const string Identity = "graph.triangle-count@1";
        internal static MathBlockOperation Create() => CreateScalar("graph.triangle-count", graph => MathBlockGraphMath.TriangleCount(graph), triangle, 1d, DimensionlessGraphScalar);
    }
}
