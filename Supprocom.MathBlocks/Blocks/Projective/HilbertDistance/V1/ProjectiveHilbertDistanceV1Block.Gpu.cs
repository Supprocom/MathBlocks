namespace Supprocom.MathBlocks.Gpu;

internal static class ProjectiveHilbertDistanceV1BlockGpu
{
    internal const string Identity = "projective.hilbert-distance@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Advanced, 12);
}
