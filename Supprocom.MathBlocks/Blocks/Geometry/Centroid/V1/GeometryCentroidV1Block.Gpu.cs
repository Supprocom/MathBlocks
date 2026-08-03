namespace Supprocom.MathBlocks.Gpu;

internal static class GeometryCentroidV1BlockGpu
{
    internal const string Identity = "geometry.centroid@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 1);
}
