namespace Supprocom.MathBlocks.Gpu;

internal static class TransportEnergyDistanceV1BlockGpu
{
    internal const string Identity = "transport.energy-distance@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Transport, 2);
}
