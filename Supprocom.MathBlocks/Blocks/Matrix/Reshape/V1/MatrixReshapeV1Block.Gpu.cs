namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixReshapeV1BlockGpu
{
    internal const string Identity = "matrix.reshape@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 17);
}
