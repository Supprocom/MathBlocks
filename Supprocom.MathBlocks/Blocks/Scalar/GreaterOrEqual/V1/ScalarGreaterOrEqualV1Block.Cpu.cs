namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarGreaterOrEqualV1BlockCpu
    {
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarComparison("scalar.greater-or-equal", (a, b) => a >= b, 2d, 2d, true);
    }
}
