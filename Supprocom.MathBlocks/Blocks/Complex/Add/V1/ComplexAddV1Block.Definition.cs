namespace Supprocom.MathBlocks;

internal static partial class ComplexMathBlocks
{
    internal static class ComplexAddV1Block
    {
        internal const string Identity = "complex.add@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateBinary("complex.add", MathBlockComplex.Add, new(1f, 2f), new(3f, -1f), new(4f, 1f), SameComplex);
    }
}
