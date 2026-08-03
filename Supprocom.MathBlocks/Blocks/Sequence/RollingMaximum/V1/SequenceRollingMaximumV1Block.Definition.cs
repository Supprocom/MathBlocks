namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class SequenceRollingMaximumV1Block
    {
        internal const string Identity = "sequence.rolling-maximum@1";
        internal static MathBlockOperation Create() => CreateRolling("sequence.rolling-maximum", MathBlockVectorMath.RollingMaximum, [2d, 3d, 4d], squaredOutput: false);
    }
}
