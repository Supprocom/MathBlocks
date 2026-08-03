namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorRankV1Block
    {
        internal const string Identity = "vector.rank@1";
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.rank", MathBlockVectorMath.Rank, [20d, 10d, 20d], [2.5d, 1d, 2.5d], DimensionlessVectorFromVector);
    }
}
