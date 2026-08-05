namespace Supprocom.MathBlocks.Cuda;

internal static class InformationConditionalMutualInformationV1BlockCuda
{
    internal const string Identity = "information.conditional-mutual-information@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 6);
}
