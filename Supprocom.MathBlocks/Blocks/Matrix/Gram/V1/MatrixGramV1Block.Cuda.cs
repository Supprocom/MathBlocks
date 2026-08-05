namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixGramV1BlockCuda
{
    internal const string Identity = "matrix.gram@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 9);
}
