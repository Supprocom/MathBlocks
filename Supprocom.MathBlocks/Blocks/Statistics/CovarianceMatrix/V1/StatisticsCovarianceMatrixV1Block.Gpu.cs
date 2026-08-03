namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsCovarianceMatrixV1BlockGpu
{
    internal const string Identity = "statistics.covariance-matrix@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 2);
}
