namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarHyperbolicSineV1BlockGpu
{
    internal const string Identity = "scalar.hyperbolic-sine@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 28);
}
