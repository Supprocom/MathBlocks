namespace Supprocom.MathBlocks.Gpu;

internal static class SequenceRollingMinimumV1BlockGpu
{
    internal const string Identity = "sequence.rolling-minimum@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 6);
}
