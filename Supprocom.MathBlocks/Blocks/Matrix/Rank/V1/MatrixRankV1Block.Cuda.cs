namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixRankV1BlockCuda
{
    internal const string Identity = "matrix.rank@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 38);
}
