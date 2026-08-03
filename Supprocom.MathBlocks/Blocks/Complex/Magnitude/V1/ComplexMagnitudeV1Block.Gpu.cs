namespace Supprocom.MathBlocks.Gpu;

internal static class ComplexMagnitudeV1BlockGpu
{
    internal const string Identity = "complex.magnitude@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Complex, 6);
}
