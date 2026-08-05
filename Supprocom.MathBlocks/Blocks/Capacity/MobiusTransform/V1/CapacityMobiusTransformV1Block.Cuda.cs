namespace Supprocom.MathBlocks.Cuda;

internal static class CapacityMobiusTransformV1BlockCuda
{
    internal const string Identity = "capacity.mobius-transform@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Advanced, 2);
}
