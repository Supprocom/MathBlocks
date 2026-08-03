namespace Supprocom.MathBlocks.Gpu;

internal static class ProbabilityLogSumExpV1BlockGpu
{
    internal const string Identity = "probability.log-sum-exp@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 22);
}
