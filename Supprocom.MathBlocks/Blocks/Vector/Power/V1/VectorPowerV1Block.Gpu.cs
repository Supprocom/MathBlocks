namespace Supprocom.MathBlocks.Gpu;

internal static class VectorPowerV1BlockGpu
{
    internal const string Identity = "vector.power@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 32);
}
