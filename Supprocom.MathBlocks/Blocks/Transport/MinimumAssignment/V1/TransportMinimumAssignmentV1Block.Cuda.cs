namespace Supprocom.MathBlocks.Cuda;

internal static class TransportMinimumAssignmentV1BlockCuda
{
    internal const string Identity = "transport.minimum-assignment@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Transport, 3);
}
