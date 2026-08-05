namespace Supprocom.MathBlocks.Cuda;

internal static class GeometryPathLengthV1BlockCuda
{
    internal const string Identity = "geometry.path-length@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 13);
}
