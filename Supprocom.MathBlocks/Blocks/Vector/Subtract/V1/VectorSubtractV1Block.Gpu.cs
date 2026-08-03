namespace Supprocom.MathBlocks.Gpu;

internal static class VectorSubtractV1BlockGpu
{
    internal const string Identity = "vector.subtract@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 47);
}
