namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsPopulationVarianceV1BlockCuda
{
    internal const string Identity = "statistics.population-variance@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 16);
}
