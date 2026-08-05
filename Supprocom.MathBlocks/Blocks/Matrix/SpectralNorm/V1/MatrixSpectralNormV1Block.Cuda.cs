namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixSpectralNormV1BlockCuda
{
    internal const string Identity = "matrix.spectral-norm@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 42);
}
