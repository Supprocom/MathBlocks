namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsLinearInterceptV1BlockGpu
{
    internal const string Identity = "statistics.linear-intercept@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 7);
}
