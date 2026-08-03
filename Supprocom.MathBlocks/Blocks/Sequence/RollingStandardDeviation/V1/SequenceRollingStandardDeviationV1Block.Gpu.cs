namespace Supprocom.MathBlocks.Gpu;

internal static class SequenceRollingStandardDeviationV1BlockGpu
{
    internal const string Identity = "sequence.rolling-standard-deviation@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 8);
}
