namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixKroneckerProductV1BlockGpu
{
    internal const string Identity = "matrix.kronecker-product@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 13);
}
