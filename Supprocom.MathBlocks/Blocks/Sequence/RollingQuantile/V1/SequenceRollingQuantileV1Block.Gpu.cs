namespace Supprocom.MathBlocks.Gpu;

internal static class SequenceRollingQuantileV1BlockGpu
{
    internal const string Identity = "sequence.rolling-quantile@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 7);
}
