namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorCumulativeSumV1Block
    {
        internal const string Identity = "vector.cumulative-sum@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Expanding;
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.cumulative-sum", MathBlockVectorMath.CumulativeSum, [1f, 2f, 3f], [1f, 3f, 6f], SameVectorUnary);
    }
}
