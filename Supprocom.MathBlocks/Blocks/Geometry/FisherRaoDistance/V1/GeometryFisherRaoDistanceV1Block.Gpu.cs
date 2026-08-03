namespace Supprocom.MathBlocks.Gpu;

internal static class GeometryFisherRaoDistanceV1BlockGpu
{
    internal const string Identity = "geometry.fisher-rao-distance@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 9);
}
