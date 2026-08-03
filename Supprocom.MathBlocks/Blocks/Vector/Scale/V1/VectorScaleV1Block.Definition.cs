namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorScaleV1Block
    {
        internal const string Identity = "vector.scale@1";
        internal static MathBlockOperation Create() => CreateVectorScalar("vector.scale", MathBlockVectorMath.Scale, 2d, [2d, 4d, 6d, 8d], ScaleType);
    }
}
