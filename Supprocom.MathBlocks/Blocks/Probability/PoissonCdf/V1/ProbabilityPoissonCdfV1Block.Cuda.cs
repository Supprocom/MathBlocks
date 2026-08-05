namespace Supprocom.MathBlocks.Cuda;

internal static class ProbabilityPoissonCdfV1BlockCuda
{
    internal const string Identity = "probability.poisson-cdf@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 25);
}
