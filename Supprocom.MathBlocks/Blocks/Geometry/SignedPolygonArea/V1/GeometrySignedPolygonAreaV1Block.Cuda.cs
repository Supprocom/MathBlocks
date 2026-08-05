namespace Supprocom.MathBlocks.Cuda;

internal static class GeometrySignedPolygonAreaV1BlockCuda
{
    internal const string Identity = "geometry.signed-polygon-area@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 17);
}
