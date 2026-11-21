namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class SequenceRollingMinimumV1Block
    {
        internal const string Identity = "sequence.rolling-minimum@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Trailing(1);
        internal static MathBlockOperation Create() => CreateRolling("sequence.rolling-minimum", MathBlockVectorMath.RollingMinimum, [1f, 2f, 3f], squaredOutput: false);
    }
}
