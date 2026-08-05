namespace Supprocom.MathBlocks.Cuda;

internal static class PointSetToMatrixV1BlockCuda
{
    internal const string Identity = "point-set.to-matrix@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 20);
}
