namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixMultiplyVectorV1BlockGpu
{
    internal const string Identity = "matrix.multiply-vector@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 14);
}
