namespace Supprocom.MathBlocks.Cuda;

internal static class GeometryDelaunayGraphV1BlockCuda
{
    internal const string Identity = "geometry.delaunay-graph@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 5);
}
