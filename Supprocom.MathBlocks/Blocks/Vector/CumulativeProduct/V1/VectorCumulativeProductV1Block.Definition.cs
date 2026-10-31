namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorCumulativeProductV1Block
    {
        internal const string Identity = "vector.cumulative-product@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Expanding;
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.cumulative-product", MathBlockVectorMath.CumulativeProduct, [1d, 2d, 3d], [1d, 2d, 6d], DimensionlessVector);
    }
}
