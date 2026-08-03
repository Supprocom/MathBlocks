namespace Supprocom.MathBlocks.Gpu;

internal static class BooleanXorV1BlockGpu
{
    internal const string Identity = "boolean.xor@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 52);
}
