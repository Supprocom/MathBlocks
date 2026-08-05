namespace Supprocom.MathBlocks.Cuda;

internal static class PolynomialBernsteinEvaluateV1BlockCuda
{
    internal const string Identity = "polynomial.bernstein-evaluate@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 17);
}
