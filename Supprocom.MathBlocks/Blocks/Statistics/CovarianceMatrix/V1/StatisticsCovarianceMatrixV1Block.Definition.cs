namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class StatisticsCovarianceMatrixV1Block
    {
        internal const string Identity = "statistics.covariance-matrix@1";
        internal static MathBlockOperation Create() => CreateUnaryMatrix("statistics.covariance-matrix", MathBlockLinearAlgebra.CovarianceMatrix, new MathBlockMatrix(2, 2, [2d / 3d, 4d / 3d, 4d / 3d, 8d / 3d]), CovarianceMatrixType, MathBlockValue.Matrix(new MathBlockMatrix(3, 2, [1d, 2d, 2d, 4d, 3d, 6d])));
    }
}
