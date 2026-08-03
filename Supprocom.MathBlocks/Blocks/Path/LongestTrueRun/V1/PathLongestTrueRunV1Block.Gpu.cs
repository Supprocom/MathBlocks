namespace Supprocom.MathBlocks.Gpu;

internal static class PathLongestTrueRunV1BlockGpu
{
    internal const string Identity = "path.longest-true-run@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 18);
}
