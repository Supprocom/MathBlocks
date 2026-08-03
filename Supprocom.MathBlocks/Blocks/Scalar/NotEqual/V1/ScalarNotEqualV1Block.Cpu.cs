namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarNotEqualV1BlockCpu
    {
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarComparison("scalar.not-equal", (a, b) => a != b, 2d, 3d, true);
    }
}
