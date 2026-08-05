namespace Supprocom.MathBlocks.Cuda;

internal static class PointSetFromMatrixV1BlockCuda
{
    internal const string Identity = "point-set.from-matrix@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 19);
}
