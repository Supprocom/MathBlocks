namespace Supprocom.MathBlocks;
internal static partial class ComplexMathBlocks
{
    internal static class ComplexConjugateV1Block
    {
        internal const string Identity = "complex.conjugate@1";
        internal static MathBlockOperation Create() => CreateUnary("complex.conjugate", MathBlockComplex.Conjugate, new(2d, -3d), new(2d, 3d), SameComplexUnary);
    }
}
