namespace Supprocom.MathBlocks.Gpu;

internal static class PolynomialDerivativeV1BlockGpu
{
    internal const string Identity = "polynomial.derivative@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 19);
}
