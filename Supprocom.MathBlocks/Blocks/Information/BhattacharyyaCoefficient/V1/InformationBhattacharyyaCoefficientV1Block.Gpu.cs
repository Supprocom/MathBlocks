namespace Supprocom.MathBlocks.Gpu;

internal static class InformationBhattacharyyaCoefficientV1BlockGpu
{
    internal const string Identity = "information.bhattacharyya-coefficient@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 4);
}
