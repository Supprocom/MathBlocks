namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorAddScalarV1Block
    {
        internal const string Identity = "vector.add-scalar@1";
        internal static MathBlockOperation Create() => CreateVectorScalar("vector.add-scalar", MathBlockVectorMath.AddScalar, 2d, [3d, 4d, 5d, 6d], AddScalarType);
    }
}
