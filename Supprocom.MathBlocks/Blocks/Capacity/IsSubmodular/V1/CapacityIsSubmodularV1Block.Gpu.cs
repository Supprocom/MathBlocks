namespace Supprocom.MathBlocks.Gpu;

internal static class CapacityIsSubmodularV1BlockGpu
{
    internal const string Identity = "capacity.is-submodular@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Advanced, 1);
}
