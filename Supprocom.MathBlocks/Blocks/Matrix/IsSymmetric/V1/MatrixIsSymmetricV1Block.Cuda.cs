namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixIsSymmetricV1BlockCuda
{
    internal const string Identity = "matrix.is-symmetric@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 31);
}
