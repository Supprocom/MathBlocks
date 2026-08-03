namespace Supprocom.MathBlocks.Gpu;

internal static class ComplexMatrixPickV1BlockGpu
{
    internal const string Identity = "complex-matrix.pick@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Complex, 18);
}
