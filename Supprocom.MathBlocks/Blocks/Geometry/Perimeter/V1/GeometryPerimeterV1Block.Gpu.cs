namespace Supprocom.MathBlocks.Gpu;

internal static class GeometryPerimeterV1BlockGpu
{
    internal const string Identity = "geometry.perimeter@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 14);
}
