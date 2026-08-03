namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarEqualV1BlockCpu
    {
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarComparison("scalar.equal", (a, b) => a == b, 2d, 2d, true);
    }
}
