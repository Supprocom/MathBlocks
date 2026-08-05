namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixStackRowsV1BlockCuda
{
    internal const string Identity = "matrix.stack-rows@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 21);
}
