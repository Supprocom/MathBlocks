namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarNaturalLogarithmV1BlockGpu
{
    internal const string Identity = "scalar.natural-logarithm@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 18);
}
