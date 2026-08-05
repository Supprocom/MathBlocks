namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixColumnSumsV1BlockCuda
{
    internal const string Identity = "matrix.column-sums@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 2);
}
