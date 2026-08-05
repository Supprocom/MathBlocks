namespace Supprocom.MathBlocks.Cuda;

internal static class GeometryContainsPointV1BlockCuda
{
    internal const string Identity = "geometry.contains-point@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 3);
}
