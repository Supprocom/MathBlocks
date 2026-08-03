namespace Supprocom.MathBlocks.Gpu;

internal static class ProbabilityPoissonPmfV1BlockGpu
{
    internal const string Identity = "probability.poisson-pmf@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 26);
}
