namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsAutocorrelationV1BlockGpu
{
    internal const string Identity = "statistics.autocorrelation@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 0);
}
