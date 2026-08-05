namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixTransposeV1BlockCuda
{
    internal const string Identity = "matrix.transpose@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 25);
}
