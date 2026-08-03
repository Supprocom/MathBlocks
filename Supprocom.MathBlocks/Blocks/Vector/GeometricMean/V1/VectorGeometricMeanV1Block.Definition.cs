namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorGeometricMeanV1Block
    {
        internal const string Identity = "vector.geometric-mean@1";
        internal static MathBlockOperation Create() => CreateReduction("vector.geometric-mean", MathBlockVectorMath.GeometricMean, Math.Pow(24d, 0.25d), MathBlockTypeRules.VectorReduction);
    }
}
