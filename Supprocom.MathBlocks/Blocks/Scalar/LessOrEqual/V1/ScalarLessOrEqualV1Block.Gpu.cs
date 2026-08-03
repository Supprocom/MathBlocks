namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarLessOrEqualV1BlockGpu
{
    internal const string Identity = "scalar.less-or-equal@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 47);
}
