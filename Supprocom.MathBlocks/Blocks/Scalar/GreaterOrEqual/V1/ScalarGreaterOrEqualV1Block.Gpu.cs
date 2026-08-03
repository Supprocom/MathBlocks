namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarGreaterOrEqualV1BlockGpu
{
    internal const string Identity = "scalar.greater-or-equal@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 49);
}
