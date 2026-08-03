namespace Supprocom.MathBlocks.Gpu;

internal static class VectorConcatenateV1BlockGpu
{
    internal const string Identity = "vector.concatenate@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 6);
}
