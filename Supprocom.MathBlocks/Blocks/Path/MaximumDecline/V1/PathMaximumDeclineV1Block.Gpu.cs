namespace Supprocom.MathBlocks.Gpu;

internal static class PathMaximumDeclineV1BlockGpu
{
    internal const string Identity = "path.maximum-decline@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 19);
}
