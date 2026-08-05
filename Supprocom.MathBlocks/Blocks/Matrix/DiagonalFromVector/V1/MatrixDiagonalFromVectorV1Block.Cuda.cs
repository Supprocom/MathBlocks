namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixDiagonalFromVectorV1BlockCuda
{
    internal const string Identity = "matrix.diagonal-from-vector@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 5);
}
