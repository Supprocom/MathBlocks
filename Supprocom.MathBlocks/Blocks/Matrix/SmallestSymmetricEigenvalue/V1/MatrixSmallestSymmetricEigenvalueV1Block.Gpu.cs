namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixSmallestSymmetricEigenvalueV1BlockGpu
{
    internal const string Identity = "matrix.smallest-symmetric-eigenvalue@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 40);
}
