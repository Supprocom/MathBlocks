namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixMaximalMinorsV1BlockGpu
{
    internal const string Identity = "matrix.maximal-minors@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 34);
}
