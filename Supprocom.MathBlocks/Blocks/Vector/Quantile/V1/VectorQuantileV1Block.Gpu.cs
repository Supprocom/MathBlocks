namespace Supprocom.MathBlocks.Gpu;

internal static class VectorQuantileV1BlockGpu
{
    internal const string Identity = "vector.quantile@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 35);
}
