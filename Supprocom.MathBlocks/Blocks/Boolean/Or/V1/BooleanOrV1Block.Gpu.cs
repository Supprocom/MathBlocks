namespace Supprocom.MathBlocks.Gpu;

internal static class BooleanOrV1BlockGpu
{
    internal const string Identity = "boolean.or@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 51);
}
