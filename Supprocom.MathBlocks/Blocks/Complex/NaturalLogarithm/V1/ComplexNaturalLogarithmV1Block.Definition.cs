namespace Supprocom.MathBlocks;

internal static partial class ComplexMathBlocks
{
    internal static class ComplexNaturalLogarithmV1Block
    {
        internal const string Identity = "complex.natural-logarithm@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateUnary("complex.natural-logarithm", MathBlockComplex.NaturalLogarithm, new Complex(1f, 0f), new Complex(0f, 0f), DimensionlessComplexUnary);
    }
}
