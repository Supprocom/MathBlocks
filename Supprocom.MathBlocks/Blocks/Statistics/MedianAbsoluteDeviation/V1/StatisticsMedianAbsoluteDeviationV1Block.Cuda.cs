namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsMedianAbsoluteDeviationV1BlockCuda
{
    internal const string Identity = "statistics.median-absolute-deviation@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 10);
}
