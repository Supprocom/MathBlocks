namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixFlattenV1BlockCuda
{
    internal const string Identity = "matrix.flatten@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 7);
}
