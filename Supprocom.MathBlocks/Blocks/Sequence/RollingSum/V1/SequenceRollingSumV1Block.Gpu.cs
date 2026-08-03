namespace Supprocom.MathBlocks.Gpu;

internal static class SequenceRollingSumV1BlockGpu
{
    internal const string Identity = "sequence.rolling-sum@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 9);
}
