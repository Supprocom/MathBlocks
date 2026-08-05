namespace Supprocom.MathBlocks.Cuda;

internal static class OrderIsotonicRegressionV1BlockCuda
{
    internal const string Identity = "order.isotonic-regression@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Advanced, 10);
}
