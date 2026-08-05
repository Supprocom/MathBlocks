namespace Supprocom.MathBlocks.Cuda;

internal static class SpecialBetaV1BlockCuda
{
    internal const string Identity = "special.beta@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 28);
}
