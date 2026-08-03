namespace Supprocom.MathBlocks.Gpu;

internal static class ProbabilityPoissonCdfV1BlockGpu
{
    internal const string Identity = "probability.poisson-cdf@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 25);
}
