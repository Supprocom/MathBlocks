namespace Supprocom.MathBlocks.Cuda;

internal static class SequenceSumOverOffsetsV1BlockCuda
{
    internal const string Identity = "sequence.sum-over-offsets@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 35);
}
