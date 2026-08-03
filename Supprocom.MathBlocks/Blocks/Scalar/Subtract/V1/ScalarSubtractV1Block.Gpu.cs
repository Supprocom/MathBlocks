namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarSubtractV1BlockGpu
{
    internal const string Identity = "scalar.subtract@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 1);
}
