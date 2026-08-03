namespace Supprocom.MathBlocks.Gpu;

internal static class ComplexVectorCreateV1BlockGpu
{
    internal const string Identity = "complex-vector.create@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Complex, 14);
}
