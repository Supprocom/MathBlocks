namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsAutocorrelationV1BlockCuda
{
    internal const string Identity = "statistics.autocorrelation@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 0);
}
