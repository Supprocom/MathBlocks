namespace Supprocom.MathBlocks.Cuda;

internal static class GeometryCentroidV1BlockCuda
{
    internal const string Identity = "geometry.centroid@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 1);
}
