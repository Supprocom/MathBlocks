namespace Supprocom.MathBlocks;
internal static partial class GraphMathBlocks
{
    internal static class GraphDegreeV1Block
    {
        internal const string Identity = "graph.degree@1";
        internal static MathBlockOperation Create() => CreateVector("graph.degree", MathBlockGraphMath.Degree, path, [1d, 2d, 1d], DimensionlessGraphVector);
    }
}
