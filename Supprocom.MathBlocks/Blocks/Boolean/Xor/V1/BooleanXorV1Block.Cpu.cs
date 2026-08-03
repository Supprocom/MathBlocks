namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class BooleanXorV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateBooleanBinary("boolean.xor", (a, b) => a ^ b, true, false, true);
    }
}
