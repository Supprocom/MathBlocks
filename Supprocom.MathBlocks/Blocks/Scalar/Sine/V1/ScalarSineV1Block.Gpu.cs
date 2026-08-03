namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarSineV1BlockGpu
{
    internal const string Identity = "scalar.sine@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 21);
}
