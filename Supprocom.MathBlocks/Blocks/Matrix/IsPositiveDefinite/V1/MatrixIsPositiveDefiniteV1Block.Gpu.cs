namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixIsPositiveDefiniteV1BlockGpu
{
    internal const string Identity = "matrix.is-positive-definite@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 30);
}
