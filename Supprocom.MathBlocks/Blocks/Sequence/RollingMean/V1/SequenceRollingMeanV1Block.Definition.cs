namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class SequenceRollingMeanV1Block
    {
        internal const string Identity = "sequence.rolling-mean@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Expanding;
        internal static MathBlockOperation Create() => CreateRolling("sequence.rolling-mean", MathBlockVectorMath.RollingMean, [1.5f, 2.5f, 3.5f], squaredOutput: false);
    }
}
