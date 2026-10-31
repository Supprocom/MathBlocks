namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorMinimumV1Block
    {
        internal const string Identity = "vector.minimum@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateReduction("vector.minimum", MathBlockVectorMath.Minimum, 1d, MathBlockTypeRules.VectorReduction);
    }
}
