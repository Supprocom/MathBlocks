namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsPopulationVarianceV1BlockGpu
{
    internal const string Identity = "statistics.population-variance@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 16);
}
