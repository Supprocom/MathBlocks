namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorMultiplyV1Block
    {
        internal const string Identity = "vector.multiply@1";
        internal static MathBlockOperation Create() => CreateVectorBinary("vector.multiply", MathBlockVectorMath.Multiply, [4d, 6d, 6d, 4d], ProductVectors);
    }
}
