namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsTheilSenSlopeV1BlockCuda
{
    internal const string Identity = "statistics.theil-sen-slope@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 24);
}
