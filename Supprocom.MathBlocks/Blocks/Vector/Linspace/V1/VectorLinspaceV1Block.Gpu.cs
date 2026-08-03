namespace Supprocom.MathBlocks.Gpu;

internal static class VectorLinspaceV1BlockGpu
{
    internal const string Identity = "vector.linspace@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 21);
}
