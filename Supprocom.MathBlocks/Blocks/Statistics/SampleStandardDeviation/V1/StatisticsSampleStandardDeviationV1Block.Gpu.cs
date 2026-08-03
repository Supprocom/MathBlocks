namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsSampleStandardDeviationV1BlockGpu
{
    internal const string Identity = "statistics.sample-standard-deviation@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 21);
}
