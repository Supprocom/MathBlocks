namespace Supprocom.MathBlocks.Gpu;

internal static class VectorExponentialV1BlockGpu
{
    internal const string Identity = "vector.exponential@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 12);
}
