namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarLogOnePlusV1BlockGpu
{
    internal const string Identity = "scalar.log-one-plus@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 42);
}
