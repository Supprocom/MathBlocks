namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarLessThanV1BlockGpu
{
    internal const string Identity = "scalar.less-than@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 46);
}
