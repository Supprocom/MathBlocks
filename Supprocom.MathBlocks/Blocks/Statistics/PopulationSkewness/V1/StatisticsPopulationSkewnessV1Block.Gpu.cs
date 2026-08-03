namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsPopulationSkewnessV1BlockGpu
{
    internal const string Identity = "statistics.population-skewness@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 14);
}
