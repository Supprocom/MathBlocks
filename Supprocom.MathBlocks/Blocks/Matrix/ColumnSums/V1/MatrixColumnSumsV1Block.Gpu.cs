namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixColumnSumsV1BlockGpu
{
    internal const string Identity = "matrix.column-sums@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 2);
}
