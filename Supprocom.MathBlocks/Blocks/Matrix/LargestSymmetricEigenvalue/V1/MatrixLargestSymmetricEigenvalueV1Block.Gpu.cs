namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixLargestSymmetricEigenvalueV1BlockGpu
{
    internal const string Identity = "matrix.largest-symmetric-eigenvalue@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 33);
}
