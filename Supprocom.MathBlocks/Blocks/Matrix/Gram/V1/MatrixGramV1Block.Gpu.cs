namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixGramV1BlockGpu
{
    internal const string Identity = "matrix.gram@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 9);
}
