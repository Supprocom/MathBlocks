namespace Supprocom.MathBlocks.Gpu;

internal static class VectorSortV1BlockGpu
{
    internal const string Identity = "vector.sort@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 43);
}
