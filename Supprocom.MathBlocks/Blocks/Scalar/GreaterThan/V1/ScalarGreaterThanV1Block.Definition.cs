namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarGreaterThanV1Block
    {
        internal const string Identity = "scalar.greater-than@1";
        internal static MathBlockOperation Create() => ScalarGreaterThanV1BlockCpu.Create();
    }
}
