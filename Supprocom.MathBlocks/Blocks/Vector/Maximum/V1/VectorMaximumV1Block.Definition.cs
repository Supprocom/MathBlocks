namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorMaximumV1Block
    {
        internal const string Identity = "vector.maximum@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateReduction("vector.maximum", MathBlockVectorMath.Maximum, 4d, MathBlockTypeRules.VectorReduction);
    }
}
