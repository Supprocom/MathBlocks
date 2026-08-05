namespace Supprocom.MathBlocks.Cuda;

internal static class PolynomialElementarySymmetricV1BlockCuda
{
    internal const string Identity = "polynomial.elementary-symmetric@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 20);
}
