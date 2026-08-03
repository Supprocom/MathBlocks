namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsSampleVarianceV1BlockGpu
{
    internal const string Identity = "statistics.sample-variance@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 22);
}
