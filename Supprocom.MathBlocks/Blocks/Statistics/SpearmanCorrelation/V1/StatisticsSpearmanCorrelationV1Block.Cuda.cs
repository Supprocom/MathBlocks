namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsSpearmanCorrelationV1BlockCuda
{
    internal const string Identity = "statistics.spearman-correlation@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 23);
}
