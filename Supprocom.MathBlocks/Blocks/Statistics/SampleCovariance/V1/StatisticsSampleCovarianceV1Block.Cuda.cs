namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsSampleCovarianceV1BlockCuda
{
    internal const string Identity = "statistics.sample-covariance@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 20);
}
