namespace Supprocom.MathBlocks.Gpu;

internal static class TransportMinimumAssignmentV1BlockGpu
{
    internal const string Identity = "transport.minimum-assignment@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Transport, 3);
}
