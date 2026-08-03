namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsKendallTauBV1BlockGpu
{
    internal const string Identity = "statistics.kendall-tau-b@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 6);
}
