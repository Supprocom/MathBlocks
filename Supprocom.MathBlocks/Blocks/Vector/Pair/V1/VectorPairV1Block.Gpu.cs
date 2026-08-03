namespace Supprocom.MathBlocks.Gpu;

internal static class VectorPairV1BlockGpu
{
    internal const string Identity = "vector.pair@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 30);
}
