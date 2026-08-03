namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarEqualV1Block
    {
        internal const string Identity = "scalar.equal@1";
        internal static MathBlockOperation Create() => ScalarEqualV1BlockCpu.Create();
    }
}
