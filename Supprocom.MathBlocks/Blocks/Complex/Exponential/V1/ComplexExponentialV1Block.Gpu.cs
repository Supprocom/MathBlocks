namespace Supprocom.MathBlocks.Gpu;

internal static class ComplexExponentialV1BlockGpu
{
    internal const string Identity = "complex.exponential@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Complex, 4);
}
