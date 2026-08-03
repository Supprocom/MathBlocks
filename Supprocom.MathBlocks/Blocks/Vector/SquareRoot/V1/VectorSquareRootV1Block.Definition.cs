namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorSquareRootV1Block
    {
        internal const string Identity = "vector.square-root@1";
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.square-root", MathBlockVectorMath.SquareRoot, [1d, 4d, 9d], [1d, 2d, 3d], SquareRootVector);
    }
}
