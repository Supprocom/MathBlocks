namespace Supprocom.MathBlocks.Cuda;

internal static class SequenceMaximumOverOffsetsV1BlockCuda
{
    internal const string Identity = "sequence.maximum-over-offsets@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 37);
}
