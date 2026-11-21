namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorMultiplyV1Block
    {
        internal const string Identity = "vector.multiply@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Pointwise;
        internal static MathBlockOperation Create() => CreateVectorBinary("vector.multiply", MathBlockVectorMath.Multiply, [4f, 6f, 6f, 4f], ProductVectors);
    }
}
