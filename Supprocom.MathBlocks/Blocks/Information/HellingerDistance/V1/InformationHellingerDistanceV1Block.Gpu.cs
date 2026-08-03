namespace Supprocom.MathBlocks.Gpu;

internal static class InformationHellingerDistanceV1BlockGpu
{
    internal const string Identity = "information.hellinger-distance@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 9);
}
