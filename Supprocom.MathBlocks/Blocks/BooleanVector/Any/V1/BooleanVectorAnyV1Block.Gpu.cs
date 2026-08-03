namespace Supprocom.MathBlocks.Gpu;

internal static class BooleanVectorAnyV1BlockGpu
{
    internal const string Identity = "boolean-vector.any@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 52);
}
