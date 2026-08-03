namespace Supprocom.MathBlocks;
internal static partial class ComplexMathBlocks
{
    internal static class ComplexSquareRootV1Block
    {
        internal const string Identity = "complex.square-root@1";
        internal static MathBlockOperation Create() => CreateUnary("complex.square-root", MathBlockComplex.SquareRoot, new(4d, 0d), new(2d, 0d), ComplexSquareRoot);
    }
}
