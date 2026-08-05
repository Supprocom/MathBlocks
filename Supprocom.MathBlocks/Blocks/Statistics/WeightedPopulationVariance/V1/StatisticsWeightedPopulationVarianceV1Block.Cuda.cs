namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsWeightedPopulationVarianceV1BlockCuda
{
    internal const string Identity = "statistics.weighted-population-variance@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 26);
}
