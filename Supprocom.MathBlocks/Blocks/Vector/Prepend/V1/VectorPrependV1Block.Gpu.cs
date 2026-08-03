namespace Supprocom.MathBlocks.Gpu;

internal static class VectorPrependV1BlockGpu
{
    internal const string Identity = "vector.prepend@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 33);
}
