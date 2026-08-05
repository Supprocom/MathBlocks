namespace Supprocom.MathBlocks.Cuda;

internal static class ProbabilitySoftmaxV1BlockCuda
{
    internal const string Identity = "probability.softmax@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 27);
}
