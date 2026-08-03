namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarArcSineV1BlockGpu
{
    internal const string Identity = "scalar.arc-sine@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 24);
}
