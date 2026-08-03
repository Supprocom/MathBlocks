namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsPopulationStandardDeviationV1BlockGpu
{
    internal const string Identity = "statistics.population-standard-deviation@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 15);
}
