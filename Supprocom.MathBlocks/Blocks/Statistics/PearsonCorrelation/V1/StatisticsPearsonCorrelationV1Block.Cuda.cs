namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsPearsonCorrelationV1BlockCuda
{
    internal const string Identity = "statistics.pearson-correlation@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 11);
}
