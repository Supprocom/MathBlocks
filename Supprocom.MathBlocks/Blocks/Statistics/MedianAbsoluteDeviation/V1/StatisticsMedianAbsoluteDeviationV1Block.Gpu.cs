namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsMedianAbsoluteDeviationV1BlockGpu
{
    internal const string Identity = "statistics.median-absolute-deviation@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 10);
}
