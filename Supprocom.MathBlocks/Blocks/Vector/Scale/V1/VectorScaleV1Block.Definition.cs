namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorScaleV1Block
    {
        internal const string Identity = "vector.scale@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Pointwise;
        internal static MathBlockOperation Create() => CreateVectorScalar("vector.scale", MathBlockVectorMath.Scale, 2f, [2f, 4f, 6f, 8f], ScaleType);
    }
}
