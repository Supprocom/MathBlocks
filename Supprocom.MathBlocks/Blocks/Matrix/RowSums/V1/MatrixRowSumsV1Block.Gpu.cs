namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixRowSumsV1BlockGpu
{
    internal const string Identity = "matrix.row-sums@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 18);
}
