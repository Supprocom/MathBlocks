namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorNaturalLogarithmV1Block
    {
        internal const string Identity = "vector.natural-logarithm@1";
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.natural-logarithm", MathBlockVectorMath.NaturalLogarithm, [1d, Math.E], [0d, 1d], DimensionlessVector);
    }
}
