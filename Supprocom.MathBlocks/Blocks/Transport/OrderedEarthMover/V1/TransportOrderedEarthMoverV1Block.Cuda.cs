namespace Supprocom.MathBlocks.Cuda;

internal static class TransportOrderedEarthMoverV1BlockCuda
{
    internal const string Identity = "transport.ordered-earth-mover@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Transport, 5);
}
