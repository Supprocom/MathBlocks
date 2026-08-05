namespace Supprocom.MathBlocks.Cuda;

internal static class CombinatoricsBinomialCoefficientV1BlockCuda
{
    internal const string Identity = "combinatorics.binomial-coefficient@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 1);
}
