namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarCommonLogarithmV1BlockGpu
{
    internal const string Identity = "scalar.common-logarithm@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 20);
}
