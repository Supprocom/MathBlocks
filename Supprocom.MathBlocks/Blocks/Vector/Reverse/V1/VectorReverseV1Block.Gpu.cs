namespace Supprocom.MathBlocks.Gpu;

internal static class VectorReverseV1BlockGpu
{
    internal const string Identity = "vector.reverse@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 38);
}
