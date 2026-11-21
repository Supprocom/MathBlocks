namespace Supprocom.MathBlocks;

internal static partial class ComplexMathBlocks
{
    internal static class ComplexDivideV1Block
    {
        internal const string Identity = "complex.divide@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateBinary("complex.divide", MathBlockComplex.Divide, new(2f, 2f), new(1f, 1f), new(2f, 0f), ComplexQuotient);
    }
}
