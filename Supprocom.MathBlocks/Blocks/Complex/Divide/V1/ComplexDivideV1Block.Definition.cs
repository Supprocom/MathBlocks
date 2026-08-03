namespace Supprocom.MathBlocks;
internal static partial class ComplexMathBlocks
{
    internal static class ComplexDivideV1Block
    {
        internal const string Identity = "complex.divide@1";
        internal static MathBlockOperation Create() => CreateBinary("complex.divide", MathBlockComplex.Divide, new(2d, 2d), new(1d, 1d), new(2d, 0d), ComplexQuotient);
    }
}
