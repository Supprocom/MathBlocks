namespace Supprocom.MathBlocks.Gpu;

internal static class VectorGreaterThanV1BlockGpu
{
    internal const string Identity = "vector.greater-than@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 15);
}
