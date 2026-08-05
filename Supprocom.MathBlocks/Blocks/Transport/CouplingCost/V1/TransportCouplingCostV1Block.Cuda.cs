namespace Supprocom.MathBlocks.Cuda;

internal static class TransportCouplingCostV1BlockCuda
{
    internal const string Identity = "transport.coupling-cost@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Transport, 1);
}
