namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsSpearmanCorrelationV1BlockGpu
{
    internal const string Identity = "statistics.spearman-correlation@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 23);
}
