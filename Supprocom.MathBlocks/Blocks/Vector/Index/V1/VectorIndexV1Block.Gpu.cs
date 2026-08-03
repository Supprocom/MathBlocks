namespace Supprocom.MathBlocks.Gpu;

internal static class VectorIndexV1BlockGpu
{
    internal const string Identity = "vector.index@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 16);
}
