namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorDivideV1Block
    {
        internal const string Identity = "vector.divide@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Pointwise;
        internal static MathBlockOperation Create() => CreateVectorBinary("vector.divide", MathBlockVectorMath.Divide, [0.25f, 2f / 3f, 1.5f, 4f], QuotientVectors);
    }
}
