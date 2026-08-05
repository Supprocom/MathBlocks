namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixExponentialV1BlockCuda
{
    internal const string Identity = "matrix.exponential@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 27);
}
