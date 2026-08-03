namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarInverseHyperbolicCosineV1BlockGpu
{
    internal const string Identity = "scalar.inverse-hyperbolic-cosine@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 32);
}
