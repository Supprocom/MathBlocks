namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixOuterProductV1BlockCuda
{
    internal const string Identity = "matrix.outer-product@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 16);
}
