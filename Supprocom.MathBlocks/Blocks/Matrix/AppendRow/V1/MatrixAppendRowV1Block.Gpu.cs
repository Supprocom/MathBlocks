namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixAppendRowV1BlockGpu
{
    internal const string Identity = "matrix.append-row@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 1);
}
