namespace Supprocom.MathBlocks;

internal static partial class ComplexMathBlocks
{
    internal static class ComplexPowerV1Block
    {
        internal const string Identity = "complex.power@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateBinary("complex.power", MathBlockComplex.Power, new(2f, 0f), new(3f, 0f), new(8f, 0f), DimensionlessComplexBinary);
    }
}
