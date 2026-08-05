namespace Supprocom.MathBlocks.Cuda;

internal static class CapacityChoquetIntegralV1BlockCuda
{
    internal const string Identity = "capacity.choquet-integral@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Advanced, 0);
}
