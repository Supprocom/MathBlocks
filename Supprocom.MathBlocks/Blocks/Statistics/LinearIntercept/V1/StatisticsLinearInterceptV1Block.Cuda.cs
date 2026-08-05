namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsLinearInterceptV1BlockCuda
{
    internal const string Identity = "statistics.linear-intercept@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 7);
}
