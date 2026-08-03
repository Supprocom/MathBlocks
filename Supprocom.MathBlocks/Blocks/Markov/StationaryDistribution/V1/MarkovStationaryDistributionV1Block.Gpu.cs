namespace Supprocom.MathBlocks.Gpu;

internal static class MarkovStationaryDistributionV1BlockGpu
{
    internal const string Identity = "markov.stationary-distribution@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Advanced, 9);
}
