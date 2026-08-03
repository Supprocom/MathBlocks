namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarGreaterThanV1BlockGpu
{
    internal const string Identity = "scalar.greater-than@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 48);
}
