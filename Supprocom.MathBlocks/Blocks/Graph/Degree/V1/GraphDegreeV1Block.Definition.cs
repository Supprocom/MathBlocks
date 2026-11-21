namespace Supprocom.MathBlocks;

internal static partial class GraphMathBlocks
{
    internal static class GraphDegreeV1Block
    {
        internal const string Identity = "graph.degree@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateVector("graph.degree", MathBlockGraphMath.Degree, path, [1f, 2f, 1f], DimensionlessGraphVector);
    }
}
