namespace Supprocom.MathBlocks.Gpu;

internal static class ComplexConjugateV1BlockGpu
{
    internal const string Identity = "complex.conjugate@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Complex, 1);
}
