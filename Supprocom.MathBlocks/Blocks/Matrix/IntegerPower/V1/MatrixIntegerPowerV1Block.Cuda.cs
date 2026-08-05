namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixIntegerPowerV1BlockCuda
{
    internal const string Identity = "matrix.integer-power@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 28);
}
