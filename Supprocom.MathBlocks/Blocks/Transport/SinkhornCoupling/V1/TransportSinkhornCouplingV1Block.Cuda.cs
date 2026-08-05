namespace Supprocom.MathBlocks.Cuda;

internal static class TransportSinkhornCouplingV1BlockCuda
{
    internal const string Identity = "transport.sinkhorn-coupling@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Transport, 6);
}
