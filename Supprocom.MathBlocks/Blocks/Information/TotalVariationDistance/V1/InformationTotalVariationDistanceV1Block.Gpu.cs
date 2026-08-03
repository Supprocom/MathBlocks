namespace Supprocom.MathBlocks.Gpu;

internal static class InformationTotalVariationDistanceV1BlockGpu
{
    internal const string Identity = "information.total-variation-distance@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 15);
}
