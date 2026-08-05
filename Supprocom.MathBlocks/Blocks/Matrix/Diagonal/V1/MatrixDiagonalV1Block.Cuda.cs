namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixDiagonalV1BlockCuda
{
    internal const string Identity = "matrix.diagonal@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 6);
}
