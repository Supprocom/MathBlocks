namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorStandardizeV1Block
    {
        internal const string Identity = "vector.standardize@1";
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.standardize", MathBlockVectorMath.Standardize, [1d, 2d, 3d], [-Math.Sqrt(1.5d), 0d, Math.Sqrt(1.5d)], DimensionlessVectorFromVector);
    }
}
