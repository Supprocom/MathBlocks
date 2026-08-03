namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixPerronValueV1BlockGpu
{
    internal const string Identity = "matrix.perron-value@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 35);
}
