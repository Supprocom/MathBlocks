namespace Supprocom.MathBlocks.Gpu;

internal static class VectorAppendV1BlockGpu
{
    internal const string Identity = "vector.append@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 3);
}
