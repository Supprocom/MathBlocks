namespace Supprocom.MathBlocks.Gpu;

internal static class VectorSliceV1BlockGpu
{
    internal const string Identity = "vector.slice@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 42);
}
