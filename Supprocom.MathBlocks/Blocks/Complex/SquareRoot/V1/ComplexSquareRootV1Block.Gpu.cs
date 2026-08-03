namespace Supprocom.MathBlocks.Gpu;

internal static class ComplexSquareRootV1BlockGpu
{
    internal const string Identity = "complex.square-root@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Complex, 12);
}
