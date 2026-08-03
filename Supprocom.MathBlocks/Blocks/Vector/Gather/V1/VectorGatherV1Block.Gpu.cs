namespace Supprocom.MathBlocks.Gpu;

internal static class VectorGatherV1BlockGpu
{
    internal const string Identity = "vector.gather@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 13);
}
