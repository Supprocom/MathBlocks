namespace Supprocom.MathBlocks.Gpu;

internal static class ComplexVectorMagnitudeV1BlockGpu
{
    internal const string Identity = "complex-vector.magnitude@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Complex, 16);
}
