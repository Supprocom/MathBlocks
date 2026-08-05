namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsLinearSlopeV1BlockCuda
{
    internal const string Identity = "statistics.linear-slope@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Statistics, 9);
}
