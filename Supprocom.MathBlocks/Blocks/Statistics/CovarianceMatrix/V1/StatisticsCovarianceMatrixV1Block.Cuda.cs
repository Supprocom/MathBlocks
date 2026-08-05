namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsCovarianceMatrixV1BlockCuda
{
    internal const string Identity = "statistics.covariance-matrix@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 2);
}
