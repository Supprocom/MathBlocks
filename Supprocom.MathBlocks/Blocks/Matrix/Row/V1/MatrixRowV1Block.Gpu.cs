namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixRowV1BlockGpu
{
    internal const string Identity = "matrix.row@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 19);
}
