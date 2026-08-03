namespace Supprocom.MathBlocks.Gpu;

internal static class ComplexNaturalLogarithmV1BlockGpu
{
    internal const string Identity = "complex.natural-logarithm@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Complex, 8);
}
