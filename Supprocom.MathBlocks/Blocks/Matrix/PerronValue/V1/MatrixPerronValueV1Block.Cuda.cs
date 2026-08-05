namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixPerronValueV1BlockCuda
{
    internal const string Identity = "matrix.perron-value@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 35);
}
