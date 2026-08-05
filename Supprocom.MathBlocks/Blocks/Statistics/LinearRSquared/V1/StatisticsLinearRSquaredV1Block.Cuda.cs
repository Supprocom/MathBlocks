namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsLinearRSquaredV1BlockCuda
{
    internal const string Identity = "statistics.linear-r-squared@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 8);
}
