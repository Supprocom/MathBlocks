namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsSampleVarianceV1BlockCuda
{
    internal const string Identity = "statistics.sample-variance@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 22);
}
