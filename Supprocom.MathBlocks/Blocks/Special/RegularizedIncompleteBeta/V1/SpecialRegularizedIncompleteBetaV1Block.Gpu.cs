namespace Supprocom.MathBlocks.Gpu;

internal static class SpecialRegularizedIncompleteBetaV1BlockGpu
{
    internal const string Identity = "special.regularized-incomplete-beta@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 30);
}
