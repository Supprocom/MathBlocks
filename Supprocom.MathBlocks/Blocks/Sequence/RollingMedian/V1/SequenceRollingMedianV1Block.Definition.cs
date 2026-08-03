namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class SequenceRollingMedianV1Block
    {
        internal const string Identity = "sequence.rolling-median@1";
        internal static MathBlockOperation Create() => CreateRolling("sequence.rolling-median", MathBlockVectorMath.RollingMedian, [1.5d, 2.5d, 3.5d], squaredOutput: false);
    }
}
