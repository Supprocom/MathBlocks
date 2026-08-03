namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsPopulationCovarianceV1BlockGpu
{
    internal const string Identity = "statistics.population-covariance@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 12);
}
