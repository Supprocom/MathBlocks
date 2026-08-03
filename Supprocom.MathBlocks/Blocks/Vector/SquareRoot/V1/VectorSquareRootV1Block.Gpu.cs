namespace Supprocom.MathBlocks.Gpu;

internal static class VectorSquareRootV1BlockGpu
{
    internal const string Identity = "vector.square-root@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 44);
}
