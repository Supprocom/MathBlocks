namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixSubtractV1BlockGpu
{
    internal const string Identity = "matrix.subtract@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 22);
}
