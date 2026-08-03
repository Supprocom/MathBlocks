namespace Supprocom.MathBlocks.Gpu;

internal static class GeometryDelaunayGraphV1BlockGpu
{
    internal const string Identity = "geometry.delaunay-graph@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 5);
}
