namespace Supprocom.MathBlocks.Gpu;

internal static class VectorPositivePartV1BlockGpu
{
    internal const string Identity = "vector.positive-part@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 31);
}
