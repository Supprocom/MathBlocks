namespace Supprocom.MathBlocks.Cuda;

internal static class TransportWeightedWasserstein1V1BlockCuda
{
    internal const string Identity = "transport.weighted-wasserstein-1@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Transport, 8);
}
