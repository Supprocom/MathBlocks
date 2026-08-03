namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorL1NormV1Block
    {
        internal const string Identity = "vector.l1-norm@1";
        internal static MathBlockOperation Create() => CreateReduction("vector.l1-norm", MathBlockVectorMath.L1Norm, 10d, MathBlockTypeRules.VectorReduction);
    }
}
