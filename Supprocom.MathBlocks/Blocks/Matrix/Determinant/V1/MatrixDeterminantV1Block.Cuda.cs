namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixDeterminantV1BlockCuda
{
    internal const string Identity = "matrix.determinant@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 26);
}
