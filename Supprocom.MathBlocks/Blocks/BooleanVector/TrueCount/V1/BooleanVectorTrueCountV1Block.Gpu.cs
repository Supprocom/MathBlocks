namespace Supprocom.MathBlocks.Gpu;

internal static class BooleanVectorTrueCountV1BlockGpu
{
    internal const string Identity = "boolean-vector.true-count@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 55);
}
