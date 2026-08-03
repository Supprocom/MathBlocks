namespace Supprocom.MathBlocks.Gpu;

internal static class VectorAddScalarV1BlockGpu
{
    internal const string Identity = "vector.add-scalar@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 1);
}
