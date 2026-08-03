namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class SequenceRollingMeanV1Block
    {
        internal const string Identity = "sequence.rolling-mean@1";
        internal static MathBlockOperation Create() => CreateRolling("sequence.rolling-mean", MathBlockVectorMath.RollingMean, [1.5d, 2.5d, 3.5d], squaredOutput: false);
    }
}
