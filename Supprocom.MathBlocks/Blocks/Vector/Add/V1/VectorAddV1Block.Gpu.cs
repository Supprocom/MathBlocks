namespace Supprocom.MathBlocks.Gpu;

internal static class VectorAddV1BlockGpu
{
    internal const string Identity = "vector.add@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 2);
}
