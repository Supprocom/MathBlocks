namespace Supprocom.MathBlocks.Gpu;

internal static class ProbabilityNormalCdfV1BlockGpu
{
    internal const string Identity = "probability.normal-cdf@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 23);
}
