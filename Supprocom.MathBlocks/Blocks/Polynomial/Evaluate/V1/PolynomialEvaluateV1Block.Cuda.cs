namespace Supprocom.MathBlocks.Cuda;

internal static class PolynomialEvaluateV1BlockCuda
{
    internal const string Identity = "polynomial.evaluate@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 21);
}
