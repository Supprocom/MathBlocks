namespace Supprocom.MathBlocks.Gpu;

internal static class PathSignatureLevelTwoV1BlockGpu
{
    internal const string Identity = "path.signature-level-two@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 28);
}
