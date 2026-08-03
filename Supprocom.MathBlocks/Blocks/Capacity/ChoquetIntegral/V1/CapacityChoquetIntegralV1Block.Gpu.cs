namespace Supprocom.MathBlocks.Gpu;

internal static class CapacityChoquetIntegralV1BlockGpu
{
    internal const string Identity = "capacity.choquet-integral@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Advanced, 0);
}
