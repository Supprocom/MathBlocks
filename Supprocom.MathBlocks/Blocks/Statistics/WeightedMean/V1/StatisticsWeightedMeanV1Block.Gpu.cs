namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsWeightedMeanV1BlockGpu
{
    internal const string Identity = "statistics.weighted-mean@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 25);
}
