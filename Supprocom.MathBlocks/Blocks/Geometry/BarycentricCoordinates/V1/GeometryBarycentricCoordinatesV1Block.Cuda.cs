namespace Supprocom.MathBlocks.Cuda;

internal static class GeometryBarycentricCoordinatesV1BlockCuda
{
    internal const string Identity = "geometry.barycentric-coordinates@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 0);
}
