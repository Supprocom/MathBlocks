namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixCommutatorV1BlockGpu
{
    internal const string Identity = "matrix.commutator@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 4);
}
