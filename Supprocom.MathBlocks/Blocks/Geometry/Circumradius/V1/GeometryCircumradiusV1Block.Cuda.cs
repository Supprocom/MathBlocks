namespace Supprocom.MathBlocks.Cuda;

internal static class GeometryCircumradiusV1BlockCuda
{
    internal const string Identity = "geometry.circumradius@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 2);
}
