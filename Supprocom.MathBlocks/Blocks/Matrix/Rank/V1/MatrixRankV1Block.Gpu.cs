namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixRankV1BlockGpu
{
    internal const string Identity = "matrix.rank@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 38);
}
