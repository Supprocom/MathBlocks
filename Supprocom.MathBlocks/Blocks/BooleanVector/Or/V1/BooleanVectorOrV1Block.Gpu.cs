namespace Supprocom.MathBlocks.Gpu;

internal static class BooleanVectorOrV1BlockGpu
{
    internal const string Identity = "boolean-vector.or@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 54);
}
