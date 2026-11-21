namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorStandardizeV1Block
    {
        internal const string Identity = "vector.standardize@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.standardize", MathBlockVectorMath.Standardize, [1f, 2f, 3f], [-Math.Sqrt(1.5f), 0f, Math.Sqrt(1.5f)], DimensionlessVectorFromVector);
    }
}
