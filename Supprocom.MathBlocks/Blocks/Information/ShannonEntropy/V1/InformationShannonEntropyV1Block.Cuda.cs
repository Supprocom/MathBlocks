namespace Supprocom.MathBlocks.Cuda;

internal static class InformationShannonEntropyV1BlockCuda
{
    internal const string Identity = "information.shannon-entropy@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 14);
}
