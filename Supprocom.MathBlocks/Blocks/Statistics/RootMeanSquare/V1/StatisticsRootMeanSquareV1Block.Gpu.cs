namespace Supprocom.MathBlocks.Gpu;

internal static class StatisticsRootMeanSquareV1BlockGpu
{
    internal const string Identity = "statistics.root-mean-square@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Statistics, 19);
}
