namespace Supprocom.MathBlocks.Gpu;

internal static class ComplexFromPolarV1BlockGpu
{
    internal const string Identity = "complex.from-polar@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Complex, 5);
}
