namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorPositivePartV1Block
    {
        internal const string Identity = "vector.positive-part@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Pointwise;
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.positive-part", MathBlockVectorMath.PositivePart, [-1f, 2f, -3f], [0f, 2f, 0f], SameVectorUnary);
    }
}
