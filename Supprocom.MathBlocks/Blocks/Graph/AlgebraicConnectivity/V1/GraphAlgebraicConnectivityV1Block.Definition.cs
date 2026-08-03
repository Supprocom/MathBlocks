namespace Supprocom.MathBlocks;
internal static partial class GraphMathBlocks
{
    internal static class GraphAlgebraicConnectivityV1Block
    {
        internal const string Identity = "graph.algebraic-connectivity@1";
        internal static MathBlockOperation Create() => CreateScalar("graph.algebraic-connectivity", MathBlockGraphMath.AlgebraicConnectivity, triangle, 3d, WeightedGraphScalar);
    }
}
