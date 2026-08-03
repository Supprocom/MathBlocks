namespace Supprocom.MathBlocks.Gpu;

internal static class VectorStandardizeV1BlockGpu
{
    internal const string Identity = "vector.standardize@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 46);
}
