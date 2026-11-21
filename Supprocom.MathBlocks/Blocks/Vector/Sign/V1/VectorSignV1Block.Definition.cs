namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorSignV1Block
    {
        internal const string Identity = "vector.sign@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Pointwise;
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.sign", MathBlockVectorMath.Sign, [-2f, 0f, 3f], [-1f, 0f, 1f], DimensionlessVectorFromVector);
    }
}
