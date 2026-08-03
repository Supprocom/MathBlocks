namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class SequenceRollingSumV1Block
    {
        internal const string Identity = "sequence.rolling-sum@1";
        internal static MathBlockOperation Create() => CreateRolling("sequence.rolling-sum", MathBlockVectorMath.RollingSum, [3d, 5d, 7d], squaredOutput: false);
    }
}
