namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixDeterminantV1Block
    {
        internal const string Identity = "matrix.determinant@1";
        internal static MathBlockOperation Create() => CreateScalarMatrixReduction("matrix.determinant", MathBlockLinearAlgebra.Determinant, matrixA, -2d, DeterminantType);
    }
}
