namespace Supprocom.MathBlocks.Gpu;

internal static class VectorDotV1BlockGpu
{
    internal const string Identity = "vector.dot@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 10);
}
