namespace Supprocom.MathBlocks.Gpu;

internal static class VectorNormalizeL2V1BlockGpu
{
    internal const string Identity = "vector.normalize-l2@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 29);
}
