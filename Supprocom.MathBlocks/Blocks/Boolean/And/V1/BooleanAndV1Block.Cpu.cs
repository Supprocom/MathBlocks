namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class BooleanAndV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateBooleanBinary("boolean.and", (a, b) => a && b, true, false, false);
    }
}
