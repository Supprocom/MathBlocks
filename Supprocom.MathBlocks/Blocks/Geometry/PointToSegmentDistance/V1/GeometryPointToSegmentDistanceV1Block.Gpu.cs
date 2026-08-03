namespace Supprocom.MathBlocks.Gpu;

internal static class GeometryPointToSegmentDistanceV1BlockGpu
{
    internal const string Identity = "geometry.point-to-segment-distance@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 15);
}
