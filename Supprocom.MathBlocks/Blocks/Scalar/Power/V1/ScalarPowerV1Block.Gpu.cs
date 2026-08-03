namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarPowerV1BlockGpu
{
    internal const string Identity = "scalar.power@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 16);
}
