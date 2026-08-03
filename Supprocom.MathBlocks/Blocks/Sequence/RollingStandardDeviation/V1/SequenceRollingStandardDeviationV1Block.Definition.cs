namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class SequenceRollingStandardDeviationV1Block
    {
        internal const string Identity = "sequence.rolling-standard-deviation@1";
        internal static MathBlockOperation Create() => CreateRolling("sequence.rolling-standard-deviation", MathBlockVectorMath.RollingStandardDeviation, [0.5d, 0.5d, 0.5d], squaredOutput: false);
    }
}
