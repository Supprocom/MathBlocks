namespace Supprocom.MathBlocks.Gpu;

internal static class GeometryContainsPointV1BlockGpu
{
    internal const string Identity = "geometry.contains-point@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 3);
}
