namespace Supprocom.MathBlocks.Gpu;

internal static class PathFirstPassageIndexV1BlockGpu
{
    internal const string Identity = "path.first-passage-index@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 15);
}
