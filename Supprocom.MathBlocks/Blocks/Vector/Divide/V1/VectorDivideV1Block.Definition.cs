namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorDivideV1Block
    {
        internal const string Identity = "vector.divide@1";
        internal static MathBlockOperation Create() => CreateVectorBinary("vector.divide", MathBlockVectorMath.Divide, [0.25d, 2d / 3d, 1.5d, 4d], QuotientVectors);
    }
}
