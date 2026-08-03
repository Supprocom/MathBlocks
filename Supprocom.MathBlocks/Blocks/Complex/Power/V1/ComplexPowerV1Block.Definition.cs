namespace Supprocom.MathBlocks;
internal static partial class ComplexMathBlocks
{
    internal static class ComplexPowerV1Block
    {
        internal const string Identity = "complex.power@1";
        internal static MathBlockOperation Create() => CreateBinary("complex.power", MathBlockComplex.Power, new(2d, 0d), new(3d, 0d), new(8d, 0d), DimensionlessComplexBinary);
    }
}
