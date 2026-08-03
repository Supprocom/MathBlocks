namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorNormalizeL2V1Block
    {
        internal const string Identity = "vector.normalize-l2@1";
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.normalize-l2", MathBlockVectorMath.NormalizeL2, [3d, 4d], [0.6d, 0.8d], DimensionlessVectorFromVector);
    }
}
