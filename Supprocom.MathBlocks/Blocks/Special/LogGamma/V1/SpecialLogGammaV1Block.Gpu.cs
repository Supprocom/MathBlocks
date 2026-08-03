namespace Supprocom.MathBlocks.Gpu;

internal static class SpecialLogGammaV1BlockGpu
{
    internal const string Identity = "special.log-gamma@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 29);
}
