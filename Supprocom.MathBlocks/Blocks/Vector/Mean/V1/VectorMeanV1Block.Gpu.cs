namespace Supprocom.MathBlocks.Gpu;

internal static class VectorMeanV1BlockGpu
{
    internal const string Identity = "vector.mean@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 23);
}
