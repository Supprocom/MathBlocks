namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixTransposeV1BlockGpu
{
    internal const string Identity = "matrix.transpose@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 25);
}
