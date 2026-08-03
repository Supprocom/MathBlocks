namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorPowerV1Block
    {
        internal const string Identity = "vector.power@1";
        internal static MathBlockOperation Create() => CreateVectorScalar("vector.power", MathBlockVectorMath.Power, 2d, [1d, 4d, 9d, 16d], DimensionlessVectorScalar);
    }
}
