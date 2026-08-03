namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorProductV1Block
    {
        internal const string Identity = "vector.product@1";
        internal static MathBlockOperation Create() => CreateReduction("vector.product", MathBlockVectorMath.Product, 24d, ProductReductionType);
    }
}
