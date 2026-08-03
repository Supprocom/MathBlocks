namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarBinaryLogarithmV1BlockGpu
{
    internal const string Identity = "scalar.binary-logarithm@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 19);
}
