namespace Supprocom.MathBlocks.Gpu;

internal static class VectorCumulativeSumV1BlockGpu
{
    internal const string Identity = "vector.cumulative-sum@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 8);
}
