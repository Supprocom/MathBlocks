namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsSampleCovarianceV1BlockGpu
{
    internal const string Identity = "statistics.sample-covariance@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 20);
}
