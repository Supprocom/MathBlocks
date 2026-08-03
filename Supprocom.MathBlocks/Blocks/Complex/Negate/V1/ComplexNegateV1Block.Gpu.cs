namespace Supprocom.MathBlocks.Gpu;

internal static class ComplexNegateV1BlockGpu
{
    internal const string Identity = "complex.negate@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Complex, 9);
}
