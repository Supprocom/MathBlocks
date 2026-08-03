namespace Supprocom.MathBlocks.Gpu;

internal static class GeometryGabrielGraphV1BlockGpu
{
    internal const string Identity = "geometry.gabriel-graph@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 10);
}
