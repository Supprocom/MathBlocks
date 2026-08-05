namespace Supprocom.MathBlocks.Cuda;

internal static class CapacityIsSubmodularV1BlockCuda
{
    internal const string Identity = "capacity.is-submodular@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Advanced, 1);
}
