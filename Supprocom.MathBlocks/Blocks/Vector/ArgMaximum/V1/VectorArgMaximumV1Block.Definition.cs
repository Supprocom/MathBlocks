namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorArgMaximumV1Block
    {
        internal const string Identity = "vector.arg-maximum@1";
        internal static MathBlockOperation Create() => CreateReduction("vector.arg-maximum", values => MathBlockVectorMath.ArgMaximum(values), 3d, DimensionlessReductionType);
    }
}
