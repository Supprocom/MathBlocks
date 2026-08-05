namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixSchurComplementV1BlockCuda
{
    internal const string Identity = "matrix.schur-complement@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 39);
}
