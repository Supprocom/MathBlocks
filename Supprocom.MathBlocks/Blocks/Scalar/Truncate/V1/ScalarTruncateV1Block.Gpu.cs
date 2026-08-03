namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarTruncateV1BlockGpu
{
    internal const string Identity = "scalar.truncate@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 37);
}
