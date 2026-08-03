namespace Supprocom.MathBlocks.Gpu;

internal static class VectorRankV1BlockGpu
{
    internal const string Identity = "vector.rank@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 36);
}
