namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixFrobeniusNormV1BlockGpu
{
    internal const string Identity = "matrix.frobenius-norm@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 8);
}
