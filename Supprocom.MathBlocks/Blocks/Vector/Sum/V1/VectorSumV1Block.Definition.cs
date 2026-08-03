namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorSumV1Block
    {
        internal const string Identity = "vector.sum@1";
        internal static MathBlockOperation Create() => CreateReduction("vector.sum", MathBlockVectorMath.Sum, 10d, MathBlockTypeRules.VectorReduction);
    }
}
