namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class SequenceRollingVarianceV1Block
    {
        internal const string Identity = "sequence.rolling-variance@1";
        internal static MathBlockOperation Create() => CreateRolling("sequence.rolling-variance", MathBlockVectorMath.RollingVariance, [0.25d, 0.25d, 0.25d], squaredOutput: true);
    }
}
