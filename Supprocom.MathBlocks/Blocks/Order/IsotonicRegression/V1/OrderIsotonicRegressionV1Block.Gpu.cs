namespace Supprocom.MathBlocks.Gpu;

internal static class OrderIsotonicRegressionV1BlockGpu
{
    internal const string Identity = "order.isotonic-regression@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Advanced, 10);
}
