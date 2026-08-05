namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixSolveV1BlockCuda
{
    internal const string Identity = "matrix.solve@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 41);
}
