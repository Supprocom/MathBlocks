namespace Supprocom.MathBlocks.Cuda;

internal static class GeometryDiameterV1BlockCuda
{
    internal const string Identity = "geometry.diameter@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 6);
}
