namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixDiagonalFromVectorV1BlockGpu
{
    internal const string Identity = "matrix.diagonal-from-vector@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 5);
}
