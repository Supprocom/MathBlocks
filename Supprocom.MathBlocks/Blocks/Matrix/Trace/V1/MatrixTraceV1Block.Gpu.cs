namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixTraceV1BlockGpu
{
    internal const string Identity = "matrix.trace@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 24);
}
