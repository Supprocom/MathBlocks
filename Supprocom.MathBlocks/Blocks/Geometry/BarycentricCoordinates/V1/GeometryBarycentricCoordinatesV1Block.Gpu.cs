namespace Supprocom.MathBlocks.Gpu;

internal static class GeometryBarycentricCoordinatesV1BlockGpu
{
    internal const string Identity = "geometry.barycentric-coordinates@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 0);
}
