namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixPrincipalMinorsV1BlockCuda
{
    internal const string Identity = "matrix.principal-minors@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 37);
}
