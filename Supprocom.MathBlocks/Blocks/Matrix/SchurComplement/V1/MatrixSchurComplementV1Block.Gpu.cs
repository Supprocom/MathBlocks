namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixSchurComplementV1BlockGpu
{
    internal const string Identity = "matrix.schur-complement@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 39);
}
