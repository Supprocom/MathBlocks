namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixMaximalMinorsV1BlockCuda
{
    internal const string Identity = "matrix.maximal-minors@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 34);
}
