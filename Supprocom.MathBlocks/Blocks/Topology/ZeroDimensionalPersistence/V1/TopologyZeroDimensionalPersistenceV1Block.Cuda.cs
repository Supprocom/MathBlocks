namespace Supprocom.MathBlocks.Cuda;

internal static class TopologyZeroDimensionalPersistenceV1BlockCuda
{
    internal const string Identity = "topology.zero-dimensional-persistence@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Geometry, 21);
}
