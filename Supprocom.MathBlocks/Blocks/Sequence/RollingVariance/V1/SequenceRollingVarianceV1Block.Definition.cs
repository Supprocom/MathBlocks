namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class SequenceRollingVarianceV1Block
    {
        internal const string Identity = "sequence.rolling-variance@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Trailing(1);
        internal static MathBlockOperation Create() => CreateRolling("sequence.rolling-variance", MathBlockVectorMath.RollingVariance, [0.25f, 0.25f, 0.25f], squaredOutput: true);
    }
}
