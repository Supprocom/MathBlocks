namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorSignV1Block
    {
        internal const string Identity = "vector.sign@1";
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.sign", MathBlockVectorMath.Sign, [-2d, 0d, 3d], [-1d, 0d, 1d], DimensionlessVectorFromVector);
    }
}
