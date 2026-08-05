namespace Supprocom.MathBlocks.Cuda;

internal static class TransportUniformWassersteinV1BlockCuda
{
    internal const string Identity = "transport.uniform-wasserstein@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Transport, 7);
}
