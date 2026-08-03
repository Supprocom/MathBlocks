namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorArgMinimumV1Block
    {
        internal const string Identity = "vector.arg-minimum@1";
        internal static MathBlockOperation Create() => CreateReduction("vector.arg-minimum", values => MathBlockVectorMath.ArgMinimum(values), 0d, DimensionlessReductionType);
    }
}
