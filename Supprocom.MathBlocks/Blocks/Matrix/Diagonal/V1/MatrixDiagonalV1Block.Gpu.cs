namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixDiagonalV1BlockGpu
{
    internal const string Identity = "matrix.diagonal@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 6);
}
