namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixHankelV1BlockGpu
{
    internal const string Identity = "matrix.hankel@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 11);
}
