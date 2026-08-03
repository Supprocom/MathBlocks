namespace Supprocom.MathBlocks.Gpu;

internal static class SequenceRollingMaximumV1BlockGpu
{
    internal const string Identity = "sequence.rolling-maximum@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 3);
}
