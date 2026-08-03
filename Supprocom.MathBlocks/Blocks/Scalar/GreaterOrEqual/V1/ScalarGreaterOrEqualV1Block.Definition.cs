namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarGreaterOrEqualV1Block
    {
        internal const string Identity = "scalar.greater-or-equal@1";
        internal static MathBlockOperation Create() => ScalarGreaterOrEqualV1BlockCpu.Create();
    }
}
