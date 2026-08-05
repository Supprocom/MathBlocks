namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixRowSumsV1BlockCuda
{
    internal const string Identity = "matrix.row-sums@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 18);
}
