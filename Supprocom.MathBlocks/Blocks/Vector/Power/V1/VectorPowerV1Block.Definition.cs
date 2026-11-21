namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorPowerV1Block
    {
        internal const string Identity = "vector.power@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Pointwise;
        internal static MathBlockOperation Create() => CreateVectorScalar("vector.power", MathBlockVectorMath.Power, 2f, [1f, 4f, 9f, 16f], DimensionlessVectorScalar);
    }
}
