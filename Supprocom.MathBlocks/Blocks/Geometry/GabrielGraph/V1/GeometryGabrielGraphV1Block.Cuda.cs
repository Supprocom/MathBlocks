namespace Supprocom.MathBlocks.Cuda;

internal static class GeometryGabrielGraphV1BlockCuda
{
    internal const string Identity = "geometry.gabriel-graph@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 10);
}
