namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorSquareV1Block
    {
        internal const string Identity = "vector.square@1";
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.square", MathBlockVectorMath.Square, [1d, 2d, 3d], [1d, 4d, 9d], SquareVector);
    }
}
