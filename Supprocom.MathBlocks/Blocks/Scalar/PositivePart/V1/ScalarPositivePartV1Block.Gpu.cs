namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarPositivePartV1BlockGpu
{
    internal const string Identity = "scalar.positive-part@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 7);
}
