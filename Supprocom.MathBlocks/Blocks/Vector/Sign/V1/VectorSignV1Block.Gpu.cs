namespace Supprocom.MathBlocks.Gpu;

internal static class VectorSignV1BlockGpu
{
    internal const string Identity = "vector.sign@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 41);
}
