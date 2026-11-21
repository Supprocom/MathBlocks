namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class SequenceRollingMedianV1Block
    {
        internal const string Identity = "sequence.rolling-median@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Trailing(1);
        internal static MathBlockOperation Create() => CreateRolling("sequence.rolling-median", MathBlockVectorMath.RollingMedian, [1.5f, 2.5f, 3.5f], squaredOutput: false);
    }
}
