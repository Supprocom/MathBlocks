namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsRootMeanSquareV1BlockCuda
{
    internal const string Identity = "statistics.root-mean-square@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 19);
}
