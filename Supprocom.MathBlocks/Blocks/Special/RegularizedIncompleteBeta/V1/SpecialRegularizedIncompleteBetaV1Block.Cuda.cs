namespace Supprocom.MathBlocks.Cuda;

internal static class SpecialRegularizedIncompleteBetaV1BlockCuda
{
    internal const string Identity = "special.regularized-incomplete-beta@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 30);
}
