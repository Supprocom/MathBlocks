namespace Supprocom.MathBlocks;

internal static partial class ComplexMathBlocks
{
    internal static class ComplexNegateV1Block
    {
        internal const string Identity = "complex.negate@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateUnary("complex.negate", MathBlockComplex.Negate, new(2f, -3f), new(-2f, 3f), SameComplexUnary);
    }
}
