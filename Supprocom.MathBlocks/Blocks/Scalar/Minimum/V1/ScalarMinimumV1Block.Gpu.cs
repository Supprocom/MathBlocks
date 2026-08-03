namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarMinimumV1BlockGpu
{
    internal const string Identity = "scalar.minimum@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 8);
}
