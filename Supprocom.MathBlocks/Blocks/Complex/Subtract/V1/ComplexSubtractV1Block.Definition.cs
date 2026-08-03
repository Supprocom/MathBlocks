namespace Supprocom.MathBlocks;
internal static partial class ComplexMathBlocks
{
    internal static class ComplexSubtractV1Block
    {
        internal const string Identity = "complex.subtract@1";
        internal static MathBlockOperation Create() => CreateBinary("complex.subtract", MathBlockComplex.Subtract, new(4d, 3d), new(1d, 2d), new(3d, 1d), SameComplex);
    }
}
