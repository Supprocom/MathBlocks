namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixIsPositiveDefiniteV1Block
    {
        internal const string Identity = "matrix.is-positive-definite@1";
        internal static MathBlockOperation Create() => CreateBooleanMatrix("matrix.is-positive-definite", MathBlockLinearAlgebra.IsPositiveDefinite, symmetric, true);
    }
}
