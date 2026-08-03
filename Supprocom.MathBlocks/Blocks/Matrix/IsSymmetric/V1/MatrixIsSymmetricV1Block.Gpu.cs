namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixIsSymmetricV1BlockGpu
{
    internal const string Identity = "matrix.is-symmetric@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 31);
}
