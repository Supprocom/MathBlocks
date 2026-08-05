namespace Supprocom.MathBlocks.Cuda;

internal static class GeometryConvexHullV1BlockCuda
{
    internal const string Identity = "geometry.convex-hull@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 4);
}
