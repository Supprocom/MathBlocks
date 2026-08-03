namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixStackRowsV1BlockGpu
{
    internal const string Identity = "matrix.stack-rows@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 21);
}
