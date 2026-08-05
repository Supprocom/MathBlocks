namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixIsTotallyNonnegativeV1BlockCuda
{
    internal const string Identity = "matrix.is-totally-nonnegative@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 32);
}
