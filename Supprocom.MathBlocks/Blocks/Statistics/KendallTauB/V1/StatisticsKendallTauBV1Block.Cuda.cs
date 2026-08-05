namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsKendallTauBV1BlockCuda
{
    internal const string Identity = "statistics.kendall-tau-b@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 6);
}
