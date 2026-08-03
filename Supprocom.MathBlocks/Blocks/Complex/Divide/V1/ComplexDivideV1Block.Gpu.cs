namespace Supprocom.MathBlocks.Gpu;

internal static class ComplexDivideV1BlockGpu
{
    internal const string Identity = "complex.divide@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Complex, 3);
}
