namespace Supprocom.MathBlocks.Gpu;

internal static class SpecialBetaV1BlockGpu
{
    internal const string Identity = "special.beta@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 28);
}
