namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixAppendRowV1BlockCuda
{
    internal const string Identity = "matrix.append-row@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 1);
}
