namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsPopulationSkewnessV1BlockCuda
{
    internal const string Identity = "statistics.population-skewness@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 14);
}
