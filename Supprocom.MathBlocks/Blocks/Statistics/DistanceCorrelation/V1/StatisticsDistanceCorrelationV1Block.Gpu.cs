namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsDistanceCorrelationV1BlockGpu
{
    internal const string Identity = "statistics.distance-correlation@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 3);
}
