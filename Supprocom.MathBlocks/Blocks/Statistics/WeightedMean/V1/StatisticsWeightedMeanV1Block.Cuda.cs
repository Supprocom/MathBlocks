namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsWeightedMeanV1BlockCuda
{
    internal const string Identity = "statistics.weighted-mean@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 25);
}
