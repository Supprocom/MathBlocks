namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorEqualV1Block
    {
        internal const string Identity = "vector.equal@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Pointwise;
        internal static MathBlockOperation Create() => CreateVectorComparison("vector.equal", MathBlockVectorMath.Equal, [false, false, false, false]);
    }
}
