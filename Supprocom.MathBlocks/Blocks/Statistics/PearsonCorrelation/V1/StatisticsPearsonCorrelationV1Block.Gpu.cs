namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsPearsonCorrelationV1BlockGpu
{
    internal const string Identity = "statistics.pearson-correlation@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 11);
}
