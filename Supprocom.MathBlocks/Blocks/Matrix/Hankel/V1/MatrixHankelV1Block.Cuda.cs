namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixHankelV1BlockCuda
{
    internal const string Identity = "matrix.hankel@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 11);
}
