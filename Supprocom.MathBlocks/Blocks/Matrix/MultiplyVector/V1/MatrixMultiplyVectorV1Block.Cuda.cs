namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixMultiplyVectorV1BlockCuda
{
    internal const string Identity = "matrix.multiply-vector@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 14);
}
