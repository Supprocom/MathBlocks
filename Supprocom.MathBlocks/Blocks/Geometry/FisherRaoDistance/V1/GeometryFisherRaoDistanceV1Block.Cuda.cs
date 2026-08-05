namespace Supprocom.MathBlocks.Cuda;

internal static class GeometryFisherRaoDistanceV1BlockCuda
{
    internal const string Identity = "geometry.fisher-rao-distance@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 9);
}
