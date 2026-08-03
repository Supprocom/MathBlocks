namespace Supprocom.MathBlocks.Gpu;

internal static class TransportWeightedWasserstein1V1BlockGpu
{
    internal const string Identity = "transport.weighted-wasserstein-1@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Transport, 8);
}
