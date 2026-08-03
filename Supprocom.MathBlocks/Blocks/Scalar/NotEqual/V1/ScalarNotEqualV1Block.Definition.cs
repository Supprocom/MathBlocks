namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarNotEqualV1Block
    {
        internal const string Identity = "scalar.not-equal@1";
        internal static MathBlockOperation Create() => ScalarNotEqualV1BlockCpu.Create();
    }
}
