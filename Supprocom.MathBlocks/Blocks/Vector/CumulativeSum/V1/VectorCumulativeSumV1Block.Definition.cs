namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorCumulativeSumV1Block
    {
        internal const string Identity = "vector.cumulative-sum@1";
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.cumulative-sum", MathBlockVectorMath.CumulativeSum, [1d, 2d, 3d], [1d, 3d, 6d], SameVectorUnary);
    }
}
