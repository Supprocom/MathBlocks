namespace Supprocom.MathBlocks.Gpu;

internal static class VectorEqualV1BlockGpu
{
    internal const string Identity = "vector.equal@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 11);
}
