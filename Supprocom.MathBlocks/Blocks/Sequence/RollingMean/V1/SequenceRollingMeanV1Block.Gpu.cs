namespace Supprocom.MathBlocks.Gpu;

internal static class SequenceRollingMeanV1BlockGpu
{
    internal const string Identity = "sequence.rolling-mean@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 4);
}
