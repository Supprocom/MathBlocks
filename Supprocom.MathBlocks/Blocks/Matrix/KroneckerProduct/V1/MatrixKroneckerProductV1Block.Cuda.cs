namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixKroneckerProductV1BlockCuda
{
    internal const string Identity = "matrix.kronecker-product@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 13);
}
