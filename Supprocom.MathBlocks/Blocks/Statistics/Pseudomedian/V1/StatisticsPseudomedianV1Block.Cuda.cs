namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsPseudomedianV1BlockCuda
{
    internal const string Identity = "statistics.pseudomedian@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 17);
}
