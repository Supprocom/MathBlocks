namespace Supprocom.MathBlocks.Gpu;

internal static class GeometryHausdorffDistanceV1BlockGpu
{
    internal const string Identity = "geometry.hausdorff-distance@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 12);
}
