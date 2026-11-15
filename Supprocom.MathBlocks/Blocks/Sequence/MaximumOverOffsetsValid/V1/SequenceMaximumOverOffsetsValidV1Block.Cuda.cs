namespace Supprocom.MathBlocks.Cuda;

internal static class SequenceMaximumOverOffsetsValidV1BlockCuda
{
    internal const string Identity = "sequence.maximum-over-offsets-valid@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 38);
}
