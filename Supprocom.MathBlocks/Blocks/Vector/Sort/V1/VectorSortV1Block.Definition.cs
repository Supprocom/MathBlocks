namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorSortV1Block
    {
        internal const string Identity = "vector.sort@1";
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.sort", MathBlockVectorMath.Sort, [3d, 1d, 2d], [1d, 2d, 3d], SameVectorUnary);
    }
}
