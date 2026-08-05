namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixInverseV1BlockCuda
{
    internal const string Identity = "matrix.inverse@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 29);
}
