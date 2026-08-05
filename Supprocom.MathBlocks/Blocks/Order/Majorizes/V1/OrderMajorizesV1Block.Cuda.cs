namespace Supprocom.MathBlocks.Cuda;

internal static class OrderMajorizesV1BlockCuda
{
    internal const string Identity = "order.majorizes@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Advanced, 11);
}
