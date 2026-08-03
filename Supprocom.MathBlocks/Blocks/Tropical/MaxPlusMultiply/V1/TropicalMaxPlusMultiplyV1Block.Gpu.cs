namespace Supprocom.MathBlocks.Gpu;

internal static class TropicalMaxPlusMultiplyV1BlockGpu
{
    internal const string Identity = "tropical.max-plus-multiply@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Transport, 9);
}
