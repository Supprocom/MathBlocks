namespace Supprocom.MathBlocks.Gpu;

internal static class PathMaximumRelativeDeclineV1BlockGpu
{
    internal const string Identity = "path.maximum-relative-decline@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 20);
}
