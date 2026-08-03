namespace Supprocom.MathBlocks.Gpu;

internal static class TropicalMinPlusMultiplyV1BlockGpu
{
    internal const string Identity = "tropical.min-plus-multiply@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Transport, 10);
}
