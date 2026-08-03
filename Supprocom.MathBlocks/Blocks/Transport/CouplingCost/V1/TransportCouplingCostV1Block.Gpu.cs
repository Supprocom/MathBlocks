namespace Supprocom.MathBlocks.Gpu;

internal static class TransportCouplingCostV1BlockGpu
{
    internal const string Identity = "transport.coupling-cost@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Transport, 1);
}
