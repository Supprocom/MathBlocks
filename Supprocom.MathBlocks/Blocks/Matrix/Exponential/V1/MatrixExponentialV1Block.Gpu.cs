namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixExponentialV1BlockGpu
{
    internal const string Identity = "matrix.exponential@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 27);
}
