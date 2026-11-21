namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorNaturalLogarithmV1Block
    {
        internal const string Identity = "vector.natural-logarithm@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Pointwise;
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.natural-logarithm", MathBlockVectorMath.NaturalLogarithm, [1f, Math.E], [0f, 1f], DimensionlessVector);
    }
}
