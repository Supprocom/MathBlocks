namespace Supprocom.MathBlocks.Gpu;

internal static class VectorCumulativeProductV1BlockGpu
{
    internal const string Identity = "vector.cumulative-product@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 7);
}
