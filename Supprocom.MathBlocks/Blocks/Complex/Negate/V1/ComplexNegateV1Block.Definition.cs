namespace Supprocom.MathBlocks;
internal static partial class ComplexMathBlocks
{
    internal static class ComplexNegateV1Block
    {
        internal const string Identity = "complex.negate@1";
        internal static MathBlockOperation Create() => CreateUnary("complex.negate", MathBlockComplex.Negate, new(2d, -3d), new(-2d, 3d), SameComplexUnary);
    }
}
