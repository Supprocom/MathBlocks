namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixToeplitzV1BlockGpu
{
    internal const string Identity = "matrix.toeplitz@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 23);
}
