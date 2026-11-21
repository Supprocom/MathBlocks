namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorSubtractV1Block
    {
        internal const string Identity = "vector.subtract@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Pointwise;
        internal static MathBlockOperation Create() => CreateVectorBinary("vector.subtract", MathBlockVectorMath.Subtract, [-3f, -1f, 1f, 3f], SameVectors);
    }
}
