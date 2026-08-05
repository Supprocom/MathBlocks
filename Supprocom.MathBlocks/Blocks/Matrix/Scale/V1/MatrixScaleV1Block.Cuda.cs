namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixScaleV1BlockCuda
{
    internal const string Identity = "matrix.scale@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 20);
}
