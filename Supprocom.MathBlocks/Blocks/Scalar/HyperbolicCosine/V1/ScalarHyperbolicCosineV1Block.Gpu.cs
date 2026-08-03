namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarHyperbolicCosineV1BlockGpu
{
    internal const string Identity = "scalar.hyperbolic-cosine@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 29);
}
