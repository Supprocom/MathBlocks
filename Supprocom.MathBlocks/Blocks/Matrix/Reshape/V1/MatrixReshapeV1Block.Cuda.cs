namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixReshapeV1BlockCuda
{
    internal const string Identity = "matrix.reshape@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 17);
}
