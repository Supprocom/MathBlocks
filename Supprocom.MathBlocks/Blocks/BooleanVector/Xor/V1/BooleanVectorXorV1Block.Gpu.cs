namespace Supprocom.MathBlocks.Gpu;

internal static class BooleanVectorXorV1BlockGpu
{
    internal const string Identity = "boolean-vector.xor@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 57);
}
