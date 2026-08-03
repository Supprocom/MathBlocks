namespace Supprocom.MathBlocks;
internal static partial class GraphMathBlocks
{
    internal static class GraphWeightedDegreeV1Block
    {
        internal const string Identity = "graph.weighted-degree@1";
        internal static MathBlockOperation Create() => CreateVector("graph.weighted-degree", MathBlockGraphMath.WeightedDegree, path, [1d, 3d, 2d], WeightedGraphVector);
    }
}
