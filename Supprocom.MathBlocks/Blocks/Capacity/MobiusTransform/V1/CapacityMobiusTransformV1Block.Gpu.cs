namespace Supprocom.MathBlocks.Gpu;

internal static class CapacityMobiusTransformV1BlockGpu
{
    internal const string Identity = "capacity.mobius-transform@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Advanced, 2);
}
