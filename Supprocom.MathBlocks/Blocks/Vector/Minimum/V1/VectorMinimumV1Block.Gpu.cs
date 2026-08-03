namespace Supprocom.MathBlocks.Gpu;

internal static class VectorMinimumV1BlockGpu
{
    internal const string Identity = "vector.minimum@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 25);
}
