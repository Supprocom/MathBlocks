namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixColumnV1BlockGpu
{
    internal const string Identity = "matrix.column@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 3);
}
