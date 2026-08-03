namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarReciprocalV1BlockGpu
{
    internal const string Identity = "scalar.reciprocal@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 11);
}
