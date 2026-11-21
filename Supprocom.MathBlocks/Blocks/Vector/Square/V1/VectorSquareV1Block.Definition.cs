namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorSquareV1Block
    {
        internal const string Identity = "vector.square@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Pointwise;
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.square", MathBlockVectorMath.Square, [1f, 2f, 3f], [1f, 4f, 9f], SquareVector);
    }
}
