namespace Supprocom.MathBlocks.Cuda;

internal static class InformationMutualInformationV1BlockCuda
{
    internal const string Identity = "information.mutual-information@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 12);
}
