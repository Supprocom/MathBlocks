namespace Supprocom.MathBlocks;

internal static partial class ComplexMathBlocks
{
    internal static class ComplexMultiplyV1Block
    {
        internal const string Identity = "complex.multiply@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateBinary("complex.multiply", MathBlockComplex.Multiply, new(1f, 2f), new(3f, 4f), new(-5f, 10f), ComplexProduct);
    }
}
