namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsRawMomentV1BlockCuda
{
    internal const string Identity = "statistics.raw-moment@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 18);
}
