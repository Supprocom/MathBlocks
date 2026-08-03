namespace Supprocom.MathBlocks.Gpu;

internal static class VectorNormalizeL1V1BlockGpu
{
    internal const string Identity = "vector.normalize-l1@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 28);
}
