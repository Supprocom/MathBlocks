namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixSymmetricEigenvaluesV1BlockCuda
{
    internal const string Identity = "matrix.symmetric-eigenvalues@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 43);
}
