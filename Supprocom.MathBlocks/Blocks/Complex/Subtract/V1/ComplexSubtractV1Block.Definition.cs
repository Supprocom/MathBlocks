namespace Supprocom.MathBlocks;

internal static partial class ComplexMathBlocks
{
    internal static class ComplexSubtractV1Block
    {
        internal const string Identity = "complex.subtract@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateBinary("complex.subtract", MathBlockComplex.Subtract, new(4f, 3f), new(1f, 2f), new(3f, 1f), SameComplex);
    }
}
