namespace Supprocom.MathBlocks.Gpu;

internal static class BooleanVectorAllV1BlockGpu
{
    internal const string Identity = "boolean-vector.all@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 50);
}
