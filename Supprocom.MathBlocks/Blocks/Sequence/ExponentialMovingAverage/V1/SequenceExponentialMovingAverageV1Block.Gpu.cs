namespace Supprocom.MathBlocks.Gpu;

internal static class SequenceExponentialMovingAverageV1BlockGpu
{
    internal const string Identity = "sequence.exponential-moving-average@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 2);
}
