namespace Supprocom.MathBlocks.Cuda;

internal static class GeometrySimplicialDepthV1BlockCuda
{
    internal const string Identity = "geometry.simplicial-depth@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 18);
}
