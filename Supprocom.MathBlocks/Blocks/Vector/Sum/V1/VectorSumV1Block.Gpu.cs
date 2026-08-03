namespace Supprocom.MathBlocks.Gpu;

internal static class VectorSumV1BlockGpu
{
    internal const string Identity = "vector.sum@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 48);
}
