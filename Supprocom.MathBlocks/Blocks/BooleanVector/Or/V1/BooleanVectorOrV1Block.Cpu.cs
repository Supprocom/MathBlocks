namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class BooleanVectorOrV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateBooleanVectorBinary("boolean-vector.or", (a, b) => a || b, [true, false, true ]);
    }
}
