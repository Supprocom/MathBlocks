namespace Supprocom.MathBlocks.Gpu;

internal static class VectorDivideV1BlockGpu
{
    internal const string Identity = "vector.divide@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 9);
}
