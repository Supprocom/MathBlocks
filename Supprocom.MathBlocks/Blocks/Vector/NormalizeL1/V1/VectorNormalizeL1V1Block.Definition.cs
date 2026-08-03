namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorNormalizeL1V1Block
    {
        internal const string Identity = "vector.normalize-l1@1";
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.normalize-l1", MathBlockVectorMath.NormalizeL1, [1d, 1d, 2d], [0.25d, 0.25d, 0.5d], DimensionlessVectorFromVector);
    }
}
