namespace Supprocom.MathBlocks.Gpu;

internal static class ComplexCreateV1BlockGpu
{
    internal const string Identity = "complex.create@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Complex, 2);
}
