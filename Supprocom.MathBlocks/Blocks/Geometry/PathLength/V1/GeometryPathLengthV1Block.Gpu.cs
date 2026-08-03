namespace Supprocom.MathBlocks.Gpu;

internal static class GeometryPathLengthV1BlockGpu
{
    internal const string Identity = "geometry.path-length@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 13);
}
