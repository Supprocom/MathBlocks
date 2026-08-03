namespace Supprocom.MathBlocks.Gpu;

internal static class GeometryDiameterV1BlockGpu
{
    internal const string Identity = "geometry.diameter@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 6);
}
