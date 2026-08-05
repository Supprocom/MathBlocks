namespace Supprocom.MathBlocks.Cuda;

internal static class InformationCrossEntropyV1BlockCuda
{
    internal const string Identity = "information.cross-entropy@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 7);
}
