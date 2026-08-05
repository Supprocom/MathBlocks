namespace Supprocom.MathBlocks.Cuda;

internal static class GeometryPointToSegmentDistanceV1BlockCuda
{
    internal const string Identity = "geometry.point-to-segment-distance@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 15);
}
