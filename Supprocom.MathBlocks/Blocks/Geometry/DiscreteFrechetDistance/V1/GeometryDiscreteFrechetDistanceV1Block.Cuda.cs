namespace Supprocom.MathBlocks.Cuda;

internal static class GeometryDiscreteFrechetDistanceV1BlockCuda
{
    internal const string Identity = "geometry.discrete-frechet-distance@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 7);
}
