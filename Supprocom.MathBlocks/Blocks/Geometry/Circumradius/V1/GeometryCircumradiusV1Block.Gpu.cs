namespace Supprocom.MathBlocks.Gpu;

internal static class GeometryCircumradiusV1BlockGpu
{
    internal const string Identity = "geometry.circumradius@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 2);
}
