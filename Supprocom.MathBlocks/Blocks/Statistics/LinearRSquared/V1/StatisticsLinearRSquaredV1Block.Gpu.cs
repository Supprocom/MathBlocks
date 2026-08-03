namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsLinearRSquaredV1BlockGpu
{
    internal const string Identity = "statistics.linear-r-squared@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 8);
}
