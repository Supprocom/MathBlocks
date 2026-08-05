namespace Supprocom.MathBlocks.Cuda;

internal static class GeometryPerimeterV1BlockCuda
{
    internal const string Identity = "geometry.perimeter@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 14);
}
