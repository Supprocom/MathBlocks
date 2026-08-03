namespace Supprocom.MathBlocks.Gpu;

internal static class VectorSquareV1BlockGpu
{
    internal const string Identity = "vector.square@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 45);
}
