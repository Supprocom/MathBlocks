namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsSampleStandardDeviationV1BlockCuda
{
    internal const string Identity = "statistics.sample-standard-deviation@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 21);
}
