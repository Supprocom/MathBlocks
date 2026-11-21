namespace Supprocom.MathBlocks;

internal static partial class ComplexMathBlocks
{
    internal static class ComplexExponentialV1Block
    {
        internal const string Identity = "complex.exponential@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateUnary("complex.exponential", MathBlockComplex.Exponential, new Complex(0f, 0f), new Complex(1f, 0f), DimensionlessComplexUnary);
    }
}
