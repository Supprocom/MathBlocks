namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixMultiplyV1BlockCuda
{
    internal const string Identity = "matrix.multiply@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 15);
}
