namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class BooleanNotV1Block
    {
        internal const string Identity = "boolean.not@1";
        internal static MathBlockOperation Create() => BooleanNotV1BlockCpu.Create();
    }
}
