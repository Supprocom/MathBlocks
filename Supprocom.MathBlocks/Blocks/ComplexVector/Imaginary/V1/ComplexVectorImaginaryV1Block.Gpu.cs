namespace Supprocom.MathBlocks.Gpu;

internal static class ComplexVectorImaginaryV1BlockGpu
{
    internal const string Identity = "complex-vector.imaginary@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Complex, 15);
}
