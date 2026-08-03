namespace Supprocom.MathBlocks.Gpu;

internal static class PathSignatureLevelOneV1BlockGpu
{
    internal const string Identity = "path.signature-level-one@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 26);
}
