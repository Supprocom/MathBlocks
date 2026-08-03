namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixHadamardProductV1BlockGpu
{
    internal const string Identity = "matrix.hadamard-product@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 10);
}
