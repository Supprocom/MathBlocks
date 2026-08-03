namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixFlattenV1BlockGpu
{
    internal const string Identity = "matrix.flatten@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 7);
}
