namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorL2NormV1Block
    {
        internal const string Identity = "vector.l2-norm@1";
        internal static MathBlockOperation Create() => CreateReduction("vector.l2-norm", MathBlockVectorMath.L2Norm, Math.Sqrt(30d), MathBlockTypeRules.VectorReduction);
    }
}
