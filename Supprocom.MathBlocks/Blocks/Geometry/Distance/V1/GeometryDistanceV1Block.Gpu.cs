namespace Supprocom.MathBlocks.Gpu;

internal static class GeometryDistanceV1BlockGpu
{
    internal const string Identity = "geometry.distance@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 8);
}
