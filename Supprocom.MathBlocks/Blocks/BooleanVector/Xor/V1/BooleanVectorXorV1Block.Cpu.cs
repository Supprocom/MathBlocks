namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class BooleanVectorXorV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateBooleanVectorBinary("boolean-vector.xor", (a, b) => a ^ b, [true, false, false ]);
    }
}
