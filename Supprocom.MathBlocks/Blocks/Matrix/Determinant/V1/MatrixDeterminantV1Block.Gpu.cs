namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixDeterminantV1BlockGpu
{
    internal const string Identity = "matrix.determinant@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 26);
}
