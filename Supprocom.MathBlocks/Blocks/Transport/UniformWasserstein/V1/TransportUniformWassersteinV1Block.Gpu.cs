namespace Supprocom.MathBlocks.Gpu;

internal static class TransportUniformWassersteinV1BlockGpu
{
    internal const string Identity = "transport.uniform-wasserstein@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Transport, 7);
}
