namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorPositivePartV1Block
    {
        internal const string Identity = "vector.positive-part@1";
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.positive-part", MathBlockVectorMath.PositivePart, [-1d, 2d, -3d], [0d, 2d, 0d], SameVectorUnary);
    }
}
