namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixScaleV1BlockGpu
{
    internal const string Identity = "matrix.scale@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 20);
}
