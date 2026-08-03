namespace Supprocom.MathBlocks.Gpu;

internal static class PolynomialElementarySymmetricV1BlockGpu
{
    internal const string Identity = "polynomial.elementary-symmetric@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 20);
}
