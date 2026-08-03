namespace Supprocom.MathBlocks.Gpu;

internal static class VectorMedianV1BlockGpu
{
    internal const string Identity = "vector.median@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 24);
}
