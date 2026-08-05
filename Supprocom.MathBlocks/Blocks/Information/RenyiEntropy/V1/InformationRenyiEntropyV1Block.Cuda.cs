namespace Supprocom.MathBlocks.Cuda;

internal static class InformationRenyiEntropyV1BlockCuda
{
    internal const string Identity = "information.renyi-entropy@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 13);
}
