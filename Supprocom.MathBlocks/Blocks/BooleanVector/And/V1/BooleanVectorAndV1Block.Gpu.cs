namespace Supprocom.MathBlocks.Gpu;

internal static class BooleanVectorAndV1BlockGpu
{
    internal const string Identity = "boolean-vector.and@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 51);
}
