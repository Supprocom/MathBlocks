namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class SequenceRollingMinimumV1Block
    {
        internal const string Identity = "sequence.rolling-minimum@1";
        internal static MathBlockOperation Create() => CreateRolling("sequence.rolling-minimum", MathBlockVectorMath.RollingMinimum, [1d, 2d, 3d], squaredOutput: false);
    }
}
