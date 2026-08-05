namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixSmallestSymmetricEigenvalueV1BlockCuda
{
    internal const string Identity = "matrix.smallest-symmetric-eigenvalue@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 40);
}
