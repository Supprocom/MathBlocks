namespace Supprocom.MathBlocks.Gpu;

internal static class PathZeroCrossingCountV1BlockGpu
{
    internal const string Identity = "path.zero-crossing-count@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 31);
}
