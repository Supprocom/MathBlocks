namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsPopulationCovarianceV1BlockCuda
{
    internal const string Identity = "statistics.population-covariance@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 12);
}
