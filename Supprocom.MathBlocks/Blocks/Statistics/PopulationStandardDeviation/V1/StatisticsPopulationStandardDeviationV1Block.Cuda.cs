namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsPopulationStandardDeviationV1BlockCuda
{
    internal const string Identity = "statistics.population-standard-deviation@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 15);
}
