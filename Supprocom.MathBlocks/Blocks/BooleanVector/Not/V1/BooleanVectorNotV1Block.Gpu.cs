namespace Supprocom.MathBlocks.Gpu;

internal static class BooleanVectorNotV1BlockGpu
{
    internal const string Identity = "boolean-vector.not@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 53);
}
