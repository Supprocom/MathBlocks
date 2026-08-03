namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarNotEqualV1BlockGpu
{
    internal const string Identity = "scalar.not-equal@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 45);
}
