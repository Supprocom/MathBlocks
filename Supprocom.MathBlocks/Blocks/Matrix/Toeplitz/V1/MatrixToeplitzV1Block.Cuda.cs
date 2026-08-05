namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixToeplitzV1BlockCuda
{
    internal const string Identity = "matrix.toeplitz@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 23);
}
