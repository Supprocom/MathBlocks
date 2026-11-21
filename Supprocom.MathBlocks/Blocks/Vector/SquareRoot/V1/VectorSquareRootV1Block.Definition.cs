namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorSquareRootV1Block
    {
        internal const string Identity = "vector.square-root@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Pointwise;
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.square-root", MathBlockVectorMath.SquareRoot, [1f, 4f, 9f], [1f, 2f, 3f], SquareRootVector);
    }
}
