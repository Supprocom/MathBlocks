namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarClampV1BlockGpu
{
    internal const string Identity = "scalar.clamp@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 10);
}
