namespace Supprocom.MathBlocks.Gpu;

internal static class PathSignatureLevelThreeV1BlockGpu
{
    internal const string Identity = "path.signature-level-three@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 27);
}
