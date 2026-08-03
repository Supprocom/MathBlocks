namespace Supprocom.MathBlocks.Gpu;

internal static class VectorArgMinimumV1BlockGpu
{
    internal const string Identity = "vector.arg-minimum@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 5);
}
