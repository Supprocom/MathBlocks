namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarSoftplusV1BlockGpu
{
    internal const string Identity = "scalar.softplus@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 41);
}
