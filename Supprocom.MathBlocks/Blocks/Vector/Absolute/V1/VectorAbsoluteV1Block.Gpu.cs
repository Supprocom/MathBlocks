namespace Supprocom.MathBlocks.Gpu;

internal static class VectorAbsoluteV1BlockGpu
{
    internal const string Identity = "vector.absolute@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 0);
}
