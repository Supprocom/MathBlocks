namespace Supprocom.MathBlocks.Gpu;

internal static class GeometrySimplicialDepthV1BlockGpu
{
    internal const string Identity = "geometry.simplicial-depth@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 18);
}
