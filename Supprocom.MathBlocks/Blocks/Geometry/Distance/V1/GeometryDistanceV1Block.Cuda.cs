namespace Supprocom.MathBlocks.Cuda;

internal static class GeometryDistanceV1BlockCuda
{
    internal const string Identity = "geometry.distance@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 8);
}
