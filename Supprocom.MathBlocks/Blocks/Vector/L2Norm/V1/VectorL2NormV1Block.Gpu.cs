namespace Supprocom.MathBlocks.Gpu;

internal static class VectorL2NormV1BlockGpu
{
    internal const string Identity = "vector.l2-norm@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 18);
}
