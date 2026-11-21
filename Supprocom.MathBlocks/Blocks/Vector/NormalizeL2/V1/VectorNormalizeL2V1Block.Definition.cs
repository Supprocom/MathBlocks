namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorNormalizeL2V1Block
    {
        internal const string Identity = "vector.normalize-l2@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.normalize-l2", MathBlockVectorMath.NormalizeL2, [3f, 4f], [0.6f, 0.8f], DimensionlessVectorFromVector);
    }
}
