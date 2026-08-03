namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsCentralMomentV1BlockGpu
{
    internal const string Identity = "statistics.central-moment@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 1);
}
