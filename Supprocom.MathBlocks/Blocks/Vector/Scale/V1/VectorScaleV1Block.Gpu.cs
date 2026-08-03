namespace Supprocom.MathBlocks.Gpu;

internal static class VectorScaleV1BlockGpu
{
    internal const string Identity = "vector.scale@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 39);
}
