namespace Supprocom.MathBlocks.Gpu;

internal static class VectorL1NormV1BlockGpu
{
    internal const string Identity = "vector.l1-norm@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 17);
}
