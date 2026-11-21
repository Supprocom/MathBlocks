namespace Supprocom.MathBlocks;

internal static partial class ComplexMathBlocks
{
    internal static class ComplexConjugateV1Block
    {
        internal const string Identity = "complex.conjugate@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateUnary("complex.conjugate", MathBlockComplex.Conjugate, new(2f, -3f), new(2f, 3f), SameComplexUnary);
    }
}
