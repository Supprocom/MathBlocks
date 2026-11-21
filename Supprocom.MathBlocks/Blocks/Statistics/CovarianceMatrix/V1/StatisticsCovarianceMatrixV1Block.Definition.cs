namespace Supprocom.MathBlocks;

internal static partial class MatrixMathBlocks
{
    internal static class StatisticsCovarianceMatrixV1Block
    {
        internal const string Identity = "statistics.covariance-matrix@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateUnaryMatrix("statistics.covariance-matrix", MathBlockLinearAlgebra.CovarianceMatrix, new MathBlockMatrix(2, 2, [2f / 3f, 4f / 3f, 4f / 3f, 8f / 3f]), CovarianceMatrixType, MathBlockValue.Matrix(new MathBlockMatrix(3, 2, [1f, 2f, 2f, 4f, 3f, 6f])));
    }
}
