namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsPseudomedianV1BlockGpu
{
    internal const string Identity = "statistics.pseudomedian@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 17);
}
