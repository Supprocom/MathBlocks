namespace Supprocom.MathBlocks.Cuda;

internal static class TransportMonotoneCouplingV1BlockCuda
{
    internal const string Identity = "transport.monotone-coupling@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Transport, 4);
}
