namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorReverseV1Block
    {
        internal const string Identity = "vector.reverse@1";
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.reverse", MathBlockVectorMath.Reverse, [1d, 2d, 3d], [3d, 2d, 1d], SameVectorUnary);
    }
}
