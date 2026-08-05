namespace Supprocom.MathBlocks.Cuda;

internal static class ProbabilityLogSumExpV1BlockCuda
{
    internal const string Identity = "probability.log-sum-exp@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 22);
}
