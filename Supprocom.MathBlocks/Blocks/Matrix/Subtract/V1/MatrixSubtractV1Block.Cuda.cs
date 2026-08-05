namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixSubtractV1BlockCuda
{
    internal const string Identity = "matrix.subtract@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 22);
}
