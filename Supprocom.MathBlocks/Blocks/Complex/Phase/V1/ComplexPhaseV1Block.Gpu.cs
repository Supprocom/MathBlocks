namespace Supprocom.MathBlocks.Gpu;

internal static class ComplexPhaseV1BlockGpu
{
    internal const string Identity = "complex.phase@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Complex, 10);
}
