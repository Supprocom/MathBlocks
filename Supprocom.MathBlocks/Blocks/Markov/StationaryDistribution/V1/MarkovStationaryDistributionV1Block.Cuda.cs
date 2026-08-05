namespace Supprocom.MathBlocks.Cuda;

internal static class MarkovStationaryDistributionV1BlockCuda
{
    internal const string Identity = "markov.stationary-distribution@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Advanced, 9);
}
