namespace Supprocom.MathBlocks.Cuda;

internal static class SurvivalProductLimitV1BlockCuda
{
    internal const string Identity = "survival.product-limit@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Advanced, 18);
}
