namespace Supprocom.MathBlocks.Gpu;

internal static class TopologyZeroDimensionalPersistenceV1BlockGpu
{
    internal const string Identity = "topology.zero-dimensional-persistence@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 21);
}
