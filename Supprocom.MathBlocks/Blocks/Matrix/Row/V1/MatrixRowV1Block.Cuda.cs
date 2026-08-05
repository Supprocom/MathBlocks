namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixRowV1BlockCuda
{
    internal const string Identity = "matrix.row@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 19);
}
