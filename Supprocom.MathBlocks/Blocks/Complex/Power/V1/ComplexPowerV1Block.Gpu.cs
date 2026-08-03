namespace Supprocom.MathBlocks.Gpu;

internal static class ComplexPowerV1BlockGpu
{
    internal const string Identity = "complex.power@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Complex, 11);
}
