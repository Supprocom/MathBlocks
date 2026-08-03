namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorExponentialV1Block
    {
        internal const string Identity = "vector.exponential@1";
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.exponential", MathBlockVectorMath.Exponential, [0d, 1d], [1d, Math.E], DimensionlessVector);
    }
}
