namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsInterquartileRangeV1BlockCuda
{
    internal const string Identity = "statistics.interquartile-range@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 5);
}
