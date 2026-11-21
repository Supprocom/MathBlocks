namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorAbsoluteV1Block
    {
        internal const string Identity = "vector.absolute@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Pointwise;
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.absolute", MathBlockVectorMath.Absolute, [-1f, 2f, -3f], [1f, 2f, 3f], SameVectorUnary);
    }
}
