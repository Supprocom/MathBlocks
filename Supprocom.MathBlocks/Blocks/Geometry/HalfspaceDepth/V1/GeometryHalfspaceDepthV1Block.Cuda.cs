namespace Supprocom.MathBlocks.Cuda;

internal static class GeometryHalfspaceDepthV1BlockCuda
{
    internal const string Identity = "geometry.halfspace-depth@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 11);
}
