namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixIsPositiveDefiniteV1BlockCuda
{
    internal const string Identity = "matrix.is-positive-definite@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 30);
}
