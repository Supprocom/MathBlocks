namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsPopulationExcessKurtosisV1BlockCuda
{
    internal const string Identity = "statistics.population-excess-kurtosis@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 13);
}
