namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class BooleanVectorAndV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateBooleanVectorBinary("boolean-vector.and", (a, b) => a && b, [false, false, true ]);
    }
}
