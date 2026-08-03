namespace Supprocom.MathBlocks.Gpu;

internal static class GeometrySignedPolygonAreaV1BlockGpu
{
    internal const string Identity = "geometry.signed-polygon-area@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 17);
}
