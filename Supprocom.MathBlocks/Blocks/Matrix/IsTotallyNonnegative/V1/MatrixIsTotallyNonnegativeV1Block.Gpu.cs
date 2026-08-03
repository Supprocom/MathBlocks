namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixIsTotallyNonnegativeV1BlockGpu
{
    internal const string Identity = "matrix.is-totally-nonnegative@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 32);
}
