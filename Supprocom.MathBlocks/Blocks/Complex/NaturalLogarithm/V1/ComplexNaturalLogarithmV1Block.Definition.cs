namespace Supprocom.MathBlocks;
internal static partial class ComplexMathBlocks
{
    internal static class ComplexNaturalLogarithmV1Block
    {
        internal const string Identity = "complex.natural-logarithm@1";
        internal static MathBlockOperation Create() => CreateUnary("complex.natural-logarithm", MathBlockComplex.NaturalLogarithm, new Complex(1d, 0d), new Complex(0d, 0d), DimensionlessComplexUnary);
    }
}
