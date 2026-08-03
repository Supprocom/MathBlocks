namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorMedianV1Block
    {
        internal const string Identity = "vector.median@1";
        internal static MathBlockOperation Create() => CreateReduction("vector.median", MathBlockVectorMath.Median, 2.5d, MathBlockTypeRules.VectorReduction);
    }
}
