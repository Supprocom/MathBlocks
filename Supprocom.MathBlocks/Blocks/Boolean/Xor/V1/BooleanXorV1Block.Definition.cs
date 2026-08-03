namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class BooleanXorV1Block
    {
        internal const string Identity = "boolean.xor@1";
        internal static MathBlockOperation Create() => BooleanXorV1BlockCpu.Create();
    }
}
