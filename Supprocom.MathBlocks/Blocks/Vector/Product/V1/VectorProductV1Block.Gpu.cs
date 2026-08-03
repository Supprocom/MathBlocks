namespace Supprocom.MathBlocks.Gpu;

internal static class VectorProductV1BlockGpu
{
    internal const string Identity = "vector.product@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 34);
}
