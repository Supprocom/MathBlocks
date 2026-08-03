namespace Supprocom.MathBlocks.Gpu;

internal static class GeometryPolygonAreaV1BlockGpu
{
    internal const string Identity = "geometry.polygon-area@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 16);
}
