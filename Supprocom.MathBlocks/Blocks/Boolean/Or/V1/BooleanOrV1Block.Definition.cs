namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class BooleanOrV1Block
    {
        internal const string Identity = "boolean.or@1";
        internal static MathBlockOperation Create() => BooleanOrV1BlockCpu.Create();
    }
}
