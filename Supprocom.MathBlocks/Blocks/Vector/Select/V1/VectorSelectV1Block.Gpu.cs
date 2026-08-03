namespace Supprocom.MathBlocks.Gpu;

internal static class VectorSelectV1BlockGpu
{
    internal const string Identity = "vector.select@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 40);
}
