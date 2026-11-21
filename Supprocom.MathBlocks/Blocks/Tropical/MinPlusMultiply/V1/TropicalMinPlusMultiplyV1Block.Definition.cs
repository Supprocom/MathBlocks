namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class TropicalMinPlusMultiplyV1Block
    {
        internal const string Identity = "tropical.min-plus-multiply@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateSemiringMultiply("tropical.min-plus-multiply", MathBlockAdvanced.MinPlusMultiply, new MathBlockMatrix(2, 2, [6f, 7f, 8f, 9f]));
    }
}
