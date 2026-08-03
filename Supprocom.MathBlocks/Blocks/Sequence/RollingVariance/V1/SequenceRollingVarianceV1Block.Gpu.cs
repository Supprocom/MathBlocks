namespace Supprocom.MathBlocks.Gpu;

internal static class SequenceRollingVarianceV1BlockGpu
{
    internal const string Identity = "sequence.rolling-variance@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 10);
}
