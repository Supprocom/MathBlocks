namespace Supprocom.MathBlocks.Cuda;

internal static class SequenceSumOverOffsetsValidV1BlockCuda
{
    internal const string Identity = "sequence.sum-over-offsets-valid@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 36);
}
