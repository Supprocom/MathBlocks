namespace Supprocom.MathBlocks.Gpu;

internal static class VectorRepeatV1BlockGpu
{
    internal const string Identity = "vector.repeat@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 37);
}
