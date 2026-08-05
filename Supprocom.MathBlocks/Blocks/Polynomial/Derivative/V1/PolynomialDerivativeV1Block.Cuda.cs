namespace Supprocom.MathBlocks.Cuda;

internal static class PolynomialDerivativeV1BlockCuda
{
    internal const string Identity = "polynomial.derivative@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 19);
}
