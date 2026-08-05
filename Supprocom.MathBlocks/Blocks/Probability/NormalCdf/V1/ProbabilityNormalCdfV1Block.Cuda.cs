namespace Supprocom.MathBlocks.Cuda;

internal static class ProbabilityNormalCdfV1BlockCuda
{
    internal const string Identity = "probability.normal-cdf@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 23);
}
