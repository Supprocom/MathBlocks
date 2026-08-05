namespace Supprocom.MathBlocks.Cuda;

internal static class GeometryPolygonAreaV1BlockCuda
{
    internal const string Identity = "geometry.polygon-area@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 16);
}
