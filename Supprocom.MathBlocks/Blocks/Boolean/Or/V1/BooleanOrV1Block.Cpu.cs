namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class BooleanOrV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateBooleanBinary("boolean.or", (a, b) => a || b, true, false, true);
    }
}
