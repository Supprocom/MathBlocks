namespace Supprocom.MathBlocks.Gpu;

internal static class OrderMajorizesV1BlockGpu
{
    internal const string Identity = "order.majorizes@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Advanced, 11);
}
