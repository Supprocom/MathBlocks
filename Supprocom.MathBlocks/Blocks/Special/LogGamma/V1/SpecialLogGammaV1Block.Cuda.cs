namespace Supprocom.MathBlocks.Cuda;

internal static class SpecialLogGammaV1BlockCuda
{
    internal const string Identity = "special.log-gamma@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 29);
}
