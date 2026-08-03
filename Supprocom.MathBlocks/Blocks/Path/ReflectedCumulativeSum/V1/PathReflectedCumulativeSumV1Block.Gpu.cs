namespace Supprocom.MathBlocks.Gpu;

internal static class PathReflectedCumulativeSumV1BlockGpu
{
    internal const string Identity = "path.reflected-cumulative-sum@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 24);
}
