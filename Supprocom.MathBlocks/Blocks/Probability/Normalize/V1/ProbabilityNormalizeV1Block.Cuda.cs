namespace Supprocom.MathBlocks.Cuda;

internal static class ProbabilityNormalizeV1BlockCuda
{
    internal const string Identity = "probability.normalize@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 24);
}
