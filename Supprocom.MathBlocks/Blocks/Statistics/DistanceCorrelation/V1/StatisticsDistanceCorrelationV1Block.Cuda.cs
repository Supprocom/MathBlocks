namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsDistanceCorrelationV1BlockCuda
{
    internal const string Identity = "statistics.distance-correlation@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 3);
}
