namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixIdentityV1BlockCuda
{
    internal const string Identity = "matrix.identity@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 12);
}
