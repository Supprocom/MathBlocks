namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixAddV1BlockCuda
{
    internal const string Identity = "matrix.add@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 0);
}
