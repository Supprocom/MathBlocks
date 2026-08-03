namespace Supprocom.MathBlocks.Gpu;

internal static class TransportAssignmentCostV1BlockGpu
{
    internal const string Identity = "transport.assignment-cost@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Transport, 0);
}
