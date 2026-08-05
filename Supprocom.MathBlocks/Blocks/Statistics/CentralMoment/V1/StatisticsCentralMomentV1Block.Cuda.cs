namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsCentralMomentV1BlockCuda
{
    internal const string Identity = "statistics.central-moment@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 1);
}
