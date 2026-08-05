namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixFrobeniusNormV1BlockCuda
{
    internal const string Identity = "matrix.frobenius-norm@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 8);
}
