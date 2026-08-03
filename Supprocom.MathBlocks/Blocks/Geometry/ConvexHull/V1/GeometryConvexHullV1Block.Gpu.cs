namespace Supprocom.MathBlocks.Gpu;

internal static class GeometryConvexHullV1BlockGpu
{
    internal const string Identity = "geometry.convex-hull@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 4);
}
