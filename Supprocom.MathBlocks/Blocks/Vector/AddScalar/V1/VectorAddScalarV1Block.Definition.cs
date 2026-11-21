namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorAddScalarV1Block
    {
        internal const string Identity = "vector.add-scalar@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Pointwise;
        internal static MathBlockOperation Create() => CreateVectorScalar("vector.add-scalar", MathBlockVectorMath.AddScalar, 2f, [3f, 4f, 5f, 6f], AddScalarType);
    }
}
