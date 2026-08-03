namespace Supprocom.MathBlocks.Gpu;

internal static class VectorLessThanV1BlockGpu
{
    internal const string Identity = "vector.less-than@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 20);
}
