namespace Supprocom.MathBlocks.Gpu;

internal static class BooleanVectorTrueIndicesV1BlockGpu
{
    internal const string Identity = "boolean-vector.true-indices@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 56);
}
