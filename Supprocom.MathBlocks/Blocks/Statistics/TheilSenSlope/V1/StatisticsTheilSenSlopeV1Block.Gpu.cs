namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsTheilSenSlopeV1BlockGpu
{
    internal const string Identity = "statistics.theil-sen-slope@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 24);
}
