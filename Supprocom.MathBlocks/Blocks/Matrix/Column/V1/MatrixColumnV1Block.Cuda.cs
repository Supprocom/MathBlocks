namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixColumnV1BlockCuda
{
    internal const string Identity = "matrix.column@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 3);
}
