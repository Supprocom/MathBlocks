namespace Supprocom.MathBlocks.Gpu;

internal static class ComplexAddV1BlockGpu
{
    internal const string Identity = "complex.add@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Complex, 0);
}
