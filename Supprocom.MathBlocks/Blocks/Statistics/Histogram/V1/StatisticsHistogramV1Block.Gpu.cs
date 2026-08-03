namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsHistogramV1BlockGpu
{
    internal const string Identity = "statistics.histogram@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 4);
}
