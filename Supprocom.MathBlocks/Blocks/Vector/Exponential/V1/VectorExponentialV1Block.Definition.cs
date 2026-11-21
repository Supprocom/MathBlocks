namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorExponentialV1Block
    {
        internal const string Identity = "vector.exponential@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Pointwise;
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.exponential", MathBlockVectorMath.Exponential, [0f, 1f], [1f, Math.E], DimensionlessVector);
    }
}
