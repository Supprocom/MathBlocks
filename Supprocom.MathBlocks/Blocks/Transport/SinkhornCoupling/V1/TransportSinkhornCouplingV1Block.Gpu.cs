namespace Supprocom.MathBlocks.Gpu;

internal static class TransportSinkhornCouplingV1BlockGpu
{
    internal const string Identity = "transport.sinkhorn-coupling@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Transport, 6);
}
