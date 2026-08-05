namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixPerronVectorV1BlockCuda
{
    internal const string Identity = "matrix.perron-vector@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 36);
}
