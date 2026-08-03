namespace Supprocom.MathBlocks.Gpu;

internal static class BooleanAndV1BlockGpu
{
    internal const string Identity = "boolean.and@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 50);
}
