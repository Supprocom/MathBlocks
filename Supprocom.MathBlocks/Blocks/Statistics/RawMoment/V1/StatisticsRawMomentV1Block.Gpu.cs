namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsRawMomentV1BlockGpu
{
    internal const string Identity = "statistics.raw-moment@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 18);
}
