namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorReverseV1Block
    {
        internal const string Identity = "vector.reverse@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Forward;
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.reverse", MathBlockVectorMath.Reverse, [1f, 2f, 3f], [3f, 2f, 1f], SameVectorUnary);
    }
}
