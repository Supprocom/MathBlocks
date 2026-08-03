namespace Supprocom.MathBlocks;
internal static partial class ComplexMathBlocks
{
    internal static class ComplexMultiplyV1Block
    {
        internal const string Identity = "complex.multiply@1";
        internal static MathBlockOperation Create() => CreateBinary("complex.multiply", MathBlockComplex.Multiply, new(1d, 2d), new(3d, 4d), new(-5d, 10d), ComplexProduct);
    }
}
