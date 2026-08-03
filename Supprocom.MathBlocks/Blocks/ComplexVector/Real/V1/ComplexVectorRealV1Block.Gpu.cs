namespace Supprocom.MathBlocks.Gpu;

internal static class ComplexVectorRealV1BlockGpu
{
    internal const string Identity = "complex-vector.real@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Complex, 17);
}
