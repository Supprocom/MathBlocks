namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixLargestSymmetricEigenvalueV1BlockCuda
{
    internal const string Identity = "matrix.largest-symmetric-eigenvalue@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 33);
}
