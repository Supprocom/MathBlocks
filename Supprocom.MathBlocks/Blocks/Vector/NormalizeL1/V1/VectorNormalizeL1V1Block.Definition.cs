namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorNormalizeL1V1Block
    {
        internal const string Identity = "vector.normalize-l1@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.normalize-l1", MathBlockVectorMath.NormalizeL1, [1f, 1f, 2f], [0.25f, 0.25f, 0.5f], DimensionlessVectorFromVector);
    }
}
