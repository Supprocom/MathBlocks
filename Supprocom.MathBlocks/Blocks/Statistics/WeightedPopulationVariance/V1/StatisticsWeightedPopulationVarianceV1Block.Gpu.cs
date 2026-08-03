namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsWeightedPopulationVarianceV1BlockGpu
{
    internal const string Identity = "statistics.weighted-population-variance@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 26);
}
