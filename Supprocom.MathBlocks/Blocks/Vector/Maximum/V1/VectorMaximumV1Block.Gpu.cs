namespace Supprocom.MathBlocks.Gpu;

internal static class VectorMaximumV1BlockGpu
{
    internal const string Identity = "vector.maximum@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 22);
}
