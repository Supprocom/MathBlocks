namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsInterquartileRangeV1BlockGpu
{
    internal const string Identity = "statistics.interquartile-range@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 5);
}
