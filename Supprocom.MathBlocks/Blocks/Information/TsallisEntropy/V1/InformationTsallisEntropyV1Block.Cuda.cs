namespace Supprocom.MathBlocks.Cuda;

internal static class InformationTsallisEntropyV1BlockCuda
{
    internal const string Identity = "information.tsallis-entropy@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 16);
}
