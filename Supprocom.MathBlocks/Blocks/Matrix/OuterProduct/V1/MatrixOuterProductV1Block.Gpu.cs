namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixOuterProductV1BlockGpu
{
    internal const string Identity = "matrix.outer-product@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 16);
}
