namespace Supprocom.MathBlocks.Gpu;

internal static class TransportOrderedEarthMoverV1BlockGpu
{
    internal const string Identity = "transport.ordered-earth-mover@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Transport, 5);
}
