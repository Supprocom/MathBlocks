namespace Supprocom.MathBlocks.Cuda;

internal static class GeometryHausdorffDistanceV1BlockCuda
{
    internal const string Identity = "geometry.hausdorff-distance@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 12);
}
