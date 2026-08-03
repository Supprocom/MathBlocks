namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarGreaterThanV1BlockCpu
    {
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarComparison("scalar.greater-than", (a, b) => a > b, 3d, 2d, true);
    }
}
