namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsLinearSlopeV1BlockGpu
{
    internal const string Identity = "statistics.linear-slope@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 9);
}
