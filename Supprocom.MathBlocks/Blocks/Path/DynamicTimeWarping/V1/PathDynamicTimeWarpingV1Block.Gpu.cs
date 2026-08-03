namespace Supprocom.MathBlocks.Gpu;

internal static class PathDynamicTimeWarpingV1BlockGpu
{
    internal const string Identity = "path.dynamic-time-warping@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 14);
}
