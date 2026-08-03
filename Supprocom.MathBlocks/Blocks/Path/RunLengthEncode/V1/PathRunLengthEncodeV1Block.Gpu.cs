namespace Supprocom.MathBlocks.Gpu;

internal static class PathRunLengthEncodeV1BlockGpu
{
    internal const string Identity = "path.run-length-encode@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 25);
}
