namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorMeanV1Block
    {
        internal const string Identity = "vector.mean@1";
        internal static MathBlockOperation Create() => CreateReduction("vector.mean", MathBlockVectorMath.Mean, 2.5d, MathBlockTypeRules.VectorReduction);
    }
}
