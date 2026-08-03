namespace Supprocom.MathBlocks.Gpu;

internal static class VectorMultiplyV1BlockGpu
{
    internal const string Identity = "vector.multiply@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 26);
}
