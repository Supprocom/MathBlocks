namespace Supprocom.MathBlocks.Cuda;

internal static class ProbabilityPoissonPmfV1BlockCuda
{
    internal const string Identity = "probability.poisson-pmf@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 26);
}
