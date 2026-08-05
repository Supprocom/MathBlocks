namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsHistogramV1BlockCuda
{
    internal const string Identity = "statistics.histogram@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 4);
}
