namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsPopulationExcessKurtosisV1BlockGpu
{
    internal const string Identity = "statistics.population-excess-kurtosis@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 13);
}
