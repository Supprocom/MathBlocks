namespace Supprocom.MathBlocks.Gpu;

internal static class PathCumulativeDeviationV1BlockGpu
{
    internal const string Identity = "path.cumulative-deviation@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 13);
}
