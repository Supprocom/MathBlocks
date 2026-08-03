namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixAddV1BlockGpu
{
    internal const string Identity = "matrix.add@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 0);
}
