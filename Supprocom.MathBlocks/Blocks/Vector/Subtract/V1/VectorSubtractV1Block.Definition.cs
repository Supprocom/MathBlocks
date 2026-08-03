namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorSubtractV1Block
    {
        internal const string Identity = "vector.subtract@1";
        internal static MathBlockOperation Create() => CreateVectorBinary("vector.subtract", MathBlockVectorMath.Subtract, [-3d, -1d, 1d, 3d], SameVectors);
    }
}
