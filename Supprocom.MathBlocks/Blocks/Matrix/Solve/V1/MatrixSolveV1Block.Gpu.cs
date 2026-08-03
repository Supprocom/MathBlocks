namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixSolveV1BlockGpu
{
    internal const string Identity = "matrix.solve@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 41);
}
