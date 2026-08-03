namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixPerronVectorV1BlockGpu
{
    internal const string Identity = "matrix.perron-vector@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 36);
}
