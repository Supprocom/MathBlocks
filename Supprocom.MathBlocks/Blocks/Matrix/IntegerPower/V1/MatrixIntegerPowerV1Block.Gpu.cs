namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixIntegerPowerV1BlockGpu
{
    internal const string Identity = "matrix.integer-power@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 28);
}
