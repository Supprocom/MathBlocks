namespace Supprocom.MathBlocks.Cuda;

internal static class PolynomialCubicRootsV1BlockCuda
{
    internal const string Identity = "polynomial.cubic-roots@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 18);
}
