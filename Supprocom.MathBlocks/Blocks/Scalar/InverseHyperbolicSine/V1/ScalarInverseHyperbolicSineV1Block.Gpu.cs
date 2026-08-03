namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarInverseHyperbolicSineV1BlockGpu
{
    internal const string Identity = "scalar.inverse-hyperbolic-sine@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 31);
}
