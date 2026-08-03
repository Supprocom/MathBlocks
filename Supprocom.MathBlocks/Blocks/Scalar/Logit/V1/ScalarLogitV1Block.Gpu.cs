namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarLogitV1BlockGpu
{
    internal const string Identity = "scalar.logit@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 40);
}
