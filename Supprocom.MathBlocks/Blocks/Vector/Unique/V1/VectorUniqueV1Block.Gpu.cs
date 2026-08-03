namespace Supprocom.MathBlocks.Gpu;

internal static class VectorUniqueV1BlockGpu
{
    internal const string Identity = "vector.unique@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 49);
}
