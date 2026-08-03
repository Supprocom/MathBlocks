namespace Supprocom.MathBlocks.Gpu;

internal static class TransportMonotoneCouplingV1BlockGpu
{
    internal const string Identity = "transport.monotone-coupling@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Transport, 4);
}
