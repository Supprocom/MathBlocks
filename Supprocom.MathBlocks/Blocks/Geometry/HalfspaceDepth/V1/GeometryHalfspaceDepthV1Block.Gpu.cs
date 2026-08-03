namespace Supprocom.MathBlocks.Gpu;

internal static class GeometryHalfspaceDepthV1BlockGpu
{
    internal const string Identity = "geometry.halfspace-depth@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 11);
}
