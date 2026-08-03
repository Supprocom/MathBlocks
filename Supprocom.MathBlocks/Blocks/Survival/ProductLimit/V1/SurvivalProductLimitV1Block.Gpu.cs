namespace Supprocom.MathBlocks.Gpu;

internal static class SurvivalProductLimitV1BlockGpu
{
    internal const string Identity = "survival.product-limit@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Advanced, 18);
}
