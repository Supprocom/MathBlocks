namespace Supprocom.MathBlocks.Cuda;

internal static class TransportEnergyDistanceV1BlockCuda
{
    internal const string Identity = "transport.energy-distance@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Transport, 2);
}
