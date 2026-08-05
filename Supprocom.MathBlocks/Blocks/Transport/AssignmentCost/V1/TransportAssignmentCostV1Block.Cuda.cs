namespace Supprocom.MathBlocks.Cuda;

internal static class TransportAssignmentCostV1BlockCuda
{
    internal const string Identity = "transport.assignment-cost@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Transport, 0);
}
