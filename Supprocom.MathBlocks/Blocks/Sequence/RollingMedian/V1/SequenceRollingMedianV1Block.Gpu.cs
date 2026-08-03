namespace Supprocom.MathBlocks.Gpu;

internal static class SequenceRollingMedianV1BlockGpu
{
    internal const string Identity = "sequence.rolling-median@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 5);
}
