namespace Supprocom.MathBlocks.Cuda;

internal static class MarkovEntropyProductionV1BlockCuda
{
    internal const string Identity = "markov.entropy-production@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Advanced, 8);
}
