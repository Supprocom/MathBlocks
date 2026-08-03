namespace Supprocom.MathBlocks.Gpu;

internal static class VectorLengthV1BlockGpu
{
    internal const string Identity = "vector.length@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 19);
}
