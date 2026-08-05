namespace Supprocom.MathBlocks.Cuda;

internal static class InformationBinaryShannonEntropyV1BlockCuda
{
    internal const string Identity = "information.binary-shannon-entropy@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 5);
}
