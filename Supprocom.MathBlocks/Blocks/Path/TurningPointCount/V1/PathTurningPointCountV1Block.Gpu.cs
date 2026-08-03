namespace Supprocom.MathBlocks.Gpu;

internal static class PathTurningPointCountV1BlockGpu
{
    internal const string Identity = "path.turning-point-count@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 30);
}
