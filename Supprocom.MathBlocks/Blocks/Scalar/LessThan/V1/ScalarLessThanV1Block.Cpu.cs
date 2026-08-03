namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarLessThanV1BlockCpu
    {
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarComparison("scalar.less-than", (a, b) => a < b, 2d, 3d, true);
    }
}
